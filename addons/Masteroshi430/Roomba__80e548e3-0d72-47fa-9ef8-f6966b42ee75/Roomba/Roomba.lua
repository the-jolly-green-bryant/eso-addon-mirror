--[[
-- Roomba
- (Thanks to BalkiTheWise for the name)
 ]]

Roomba = {
    name = "Roomba",
    author = "|c3CB371@Masteroshi430|r, Wobin, CrazyDutchGuy, Ayantir & silvereyes",
    version = "2026.08.12",
    website = "http://www.esoui.com/downloads/info402-Roomba.html",
    debugMode = false,
}

local db
local defaults = {
    liteMode = false,
    RoombaAtGBank = true,
    RoombaPosition = KEYBIND_STRIP_ALIGN_LEFT,
}
local addon = Roomba
local DELAY = 100
local currentRun = {}
local currentBank
local checkingBank
local restackInProgress
local duplicates = {}
-- 05/07/2026 performance improvement: cache the progress-bar totals instead of
-- recomputing them with a full table scan on every single restacked item (see
-- RestackGuildbank below for details).
local duplicatesTotal = 0
local processedCount = 0
local descriptorName = addon.name
local UI
local inBagCollection = {}
local cSlot
local cSlotIdx
local cInstanceId
local cItemDuplicateList
local keyBindIndex = 1
local waitingRetries = 1
local keybindCheck
local keybindDescriptor
-- Forward-declared (same pattern as Debug above): defined later, near InitializeKeybind,
-- but RoombaReady (defined earlier in the file) needs to call it, and a plain local
-- function declared later wouldn't be visible yet at that point in the source.
local BuildKeybindDescriptor
local currentReturnIndex
local lastRestackResult = {}
local itemIndex
local slotIndex
local qtyToMoveToGuildBank
local Debug
-- 05/07/2026 bugfix: these were previously implicit globals (assigned without `local`,
-- e.g. `liteModeGslot = gslot`), meaning they lived in the shared global namespace where
-- any other addon defining a variable with the exact same name could silently clash with
-- and corrupt Roomba's Lite-mode state. Declaring them local here fixes that, with no
-- behavior change for Roomba itself.
local liteModeGslot
local liteModeThatItemInstanceId

function Debug(message)
    if Roomba.debugMode then
        d("[RB-DEBUG] " .. message)
    end
end

-- Flag for other addons. Returns true while Roomba restacks
function addon.WorkInProgress()
    return restackInProgress
end

-- this excludes unstackable siege weapons 
-- 05/07/2026 performance improvement:
-- This function runs on EVERY slot scanned (full bag/guild-bank scans, restack loops, etc.),
-- so it's the hottest path in the addon. It used to unconditionally call GetItemLink()
-- (builds a full formatted item-link string) and ZO_LinkHandler_ParseLink() (parses that
-- string) for every single item, purely to feed a check that only ever matters for the
-- rare ITEMTYPE_SIEGE case. GetItemLink/ZO_LinkHandler_ParseLink are relatively costly
-- string-building/parsing calls, so paying that cost for ~100% of items to serve a <1%
-- case caused unnecessary CPU/GC pressure and scan slowdowns on large bags/guild banks.
-- Fix: check itemType first and only build+parse the link when the item is actually siege,
-- skipping the expensive call entirely for every normal (non-siege) item.
function GetRealSlotStackSize(sourceBag, slotIndex)

    local stack, maxStack = GetSlotStackSize(sourceBag, slotIndex)
    local itemType = GetItemType(sourceBag, slotIndex)

    -- Only pay the cost of building/parsing the item link for siege weapons
    if itemType == ITEMTYPE_SIEGE then
        local itemLink = GetItemLink(sourceBag, slotIndex, LINK_STYLE_BRACKETS)
        local hp = select(23, ZO_LinkHandler_ParseLink(itemLink))
        if hp ~= "0" then -- and hp ~= tostring(GetItemLinkSiegeMaxHP(itemLink))
            maxStack = 1
        end
    end

    return stack, maxStack 
end

-- Scan in a stackable bag
local function ScanInStackableBag(bagToScan)

    local lookUp = {}
    local duplitemp = {}
    duplicates = {}
    
    -- We only need to store slots with items
    for index, slot in pairs(bagToScan) do
        
        -- Stack at max?
        local stack, maxStack = GetRealSlotStackSize(slot.bagId, slot.slotIndex)
        
        -- Stack is not at max
        if stack ~= maxStack then
            
            -- itemId
            local itemInstanceId = slot.itemInstanceId
            
            -- We already find this item before
            if lookUp[itemInstanceId] then
                -- Already marked as duplicate?
                if not duplitemp[itemInstanceId] then
                    -- Duplicate
                    duplitemp[itemInstanceId] = lookUp[itemInstanceId]
                end
            else
                -- New item found
                lookUp[itemInstanceId] = {}
            end
            
            -- Now group all items by id
            table.insert(lookUp[itemInstanceId], {slotId = slot.slotIndex, stack = stack, texture = slot.iconFile, name = slot.name, itemInstanceId = slot.itemInstanceId})
            
        end
        
    end
    
    for _, data in pairs(duplitemp) do
        table.insert(duplicates, data)
    end

    -- 05/07/2026 performance improvement: the total number of duplicate groups is fixed
    -- for the whole restack run once the scan is done, so compute it here ONCE instead of
    -- re-counting the whole `duplicates` table (via NonContiguousCount) on every single
    -- item processed later in RestackGuildbank. See RestackGuildbank for the other half
    -- of this fix.
    duplicatesTotal = NonContiguousCount(duplicates)
    processedCount = 0

end


-- Roomba Lite : Scan only what we sent to guild bank 
local function registerThisItem()

        -- 5 slots Needed to Work
    if not CheckInventorySpaceAndWarn(5) then return end

    if not DoesGuildHavePrivilege(currentBank, GUILD_PRIVILEGE_BANK_DEPOSIT) then return end
        -- If no permission, don't do
    if not DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_DEPOSIT) or not DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_WITHDRAW) then return end	
	

    local lookUp = {}
    local duplitemp = {}
    duplicates = {}
    
	local gslot = liteModeGslot or 0
	if gslot == 0 then return end
	local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
	
	local ThatItemInstanceId = GetItemInstanceId(BAG_GUILDBANK, gslot)
	liteModeThatItemInstanceId = ThatItemInstanceId 
	
	
    -- We only need to store slots with items
    for index, slot in pairs(bagToScan) do
	   
        if slot.itemInstanceId == ThatItemInstanceId then
			-- Stack at max?
			local stack, maxStack = GetRealSlotStackSize(slot.bagId, slot.slotIndex)
			
			-- Stack is not at max
			if stack ~= maxStack then
				
				-- itemId
				local itemInstanceId = slot.itemInstanceId
				
				-- We already find this item before
				if lookUp[itemInstanceId] then
					-- Already marked as duplicate?
					if not duplitemp[itemInstanceId] then
						-- Duplicate
						duplitemp[itemInstanceId] = lookUp[itemInstanceId]
					end
				else
					-- New item found
					lookUp[itemInstanceId] = {}
				end
				
				-- Now group all items by id
				table.insert(lookUp[itemInstanceId], {slotId = slot.slotIndex, stack = stack, texture = slot.iconFile, name = slot.name, itemInstanceId = slot.itemInstanceId})
				
			end
			
        end
    end
    
    for _, data in pairs(duplitemp) do
        table.insert(duplicates, data)
    end

    -- 05/07/2026 performance improvement: same fix as ScanInStackableBag - cache the
    -- total once here instead of letting RestackGuildbank recompute it via a full
    -- table scan on every processed item.
    duplicatesTotal = NonContiguousCount(duplicates)
    processedCount = 0
	
	addon.BeginStackingProcess()
end


-- Bank is ready! Find those duplicates! Runs when EVENT_GUILD_BANK_ITEMS_READY + 1s
local function RoombaReady()

    if db.liteMode then return end -- roomba lite
    
    -- Are we in the process of checking the bank? Need to protect due to Keybinding
    if (not checkingBank) then return end
    
    local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
    
    -- If Guild does not get a bank , should not happend
    if DoesGuildHavePrivilege(currentBank, GUILD_PRIVILEGE_BANK_DEPOSIT) then
        -- If no permission, don't do
        if DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_DEPOSIT) and DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_WITHDRAW) then
            
            ScanInStackableBag(bagToScan)
			
            -- If they're is no buttons, add them
            if not KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
                if not KEYBIND_STRIP[keybindCheck] then
                    -- 05/07/2026 bugfix: rebuild with the current keyBindIndex (normally 1,
                    -- reset by StopStackingProcess) so a previous session's slot-2 fallback
                    -- doesn't linger if slot 1 is free again this time.
                    BuildKeybindDescriptor()
                    KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor)
                elseif not KEYBIND_STRIP[keybindCheck][2] then
                    keyBindIndex = 2
                    -- 05/07/2026 bugfix: keybindDescriptor must be rebuilt for the new
                    -- keyBindIndex to actually place the button at slot 2 - see
                    -- BuildKeybindDescriptor for the full explanation.
                    BuildKeybindDescriptor()
                    KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor)
                end
            -- Update descriptors. Descriptors update will call Roomba.HaveStuffToStack and show Restack button if needed
            elseif KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
                KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
            end
            
            currentRun = {}
            processedCount = 0
            
        else
            if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor)
            end
        end
    end
    
end

local function StopStackingProcess()

    Debug("StopStackingProcess()")
    cInstanceId = nil
    cSlotIdx = nil
    cSlot = nil
    inBagCollection = {}
    currentReturnIndex = nil
    restackInProgress = false
    keyBindIndex = 1
    waitingRetries = 1
    
end

-- Stop a Guild bank restack and do another scan
local function StopGBRestackAndRestartScan()

    local self = addon
    Debug("StopGBRestackAndRestartScan()")
    
    -- Unregister
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    if not db.liteMode then EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_ITEM_ADDED) end -- roomba lite
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    
    -- Kick off the next transaction
    StopStackingProcess()
	
        
    -- Now rescan and show/hide roomba button
    UI:GetNamedChild("Description"):SetText("Complete")
    UI:SetHidden(true)

	
    -- Perform another scan if an addon played with GuildBank while we restacking
	RoombaReady()

end

-- Trigger when  :
-- EVENT_GUILD_BANK_TRANSFER_ERROR
-- Called by itself
-- Called by OnGuildBankItemAdded (EVENT_GUILD_BANK_ITEM_ADDED)
local function ReturnItemsToBank(_, errorCode)
    local self = addon
    Debug("ReturnItemsToBank(_, " .. tostring(errorCode) .. ")")
    
    -- Protect for fast Escape while we restack
    if (not checkingBank) then
        StopGBRestackAndRestartScan()
        return
    end
    
    if errorCode == GUILD_BANK_NO_SPACE_LEFT then
    
        -- Stop. Guild Bank is full, User need to clean it manually        
        StopGBRestackAndRestartScan()
        return
    
    -- Can occur if an addon has destroyed our item while we were restacking
    elseif errorCode == GUILD_BANK_ITEM_NOT_FOUND then
        
        -- Need to move to next stack
        
        -- Let's try next try of the same item. Is there another stack to move?
        if next(lastRestackResult[itemIndex], slotIndex) then
            
            -- yes, try to move it
            slotIndex = slotIndex + 1
            
            Debug("zo_callLater(ReturnItemsToBank, " .. tostring(DELAY) .. "), slotIndex=" .. tostring(slotIndex) .. ", itemIndex=" .. tostring(itemIndex))
            zo_callLater(ReturnItemsToBank, DELAY)
            
        -- No more stack. Maybe another item?
        elseif next(lastRestackResult, itemIndex) then
            -- Yes, move its first stack
            itemIndex = itemIndex + 1
            slotIndex = 1
            
            Debug("zo_callLater(ReturnItemsToBank, " .. tostring(DELAY) .. "), slotIndex=1, itemIndex=" .. tostring(itemIndex))
            zo_callLater(ReturnItemsToBank, DELAY)
            
        else
            -- Nothing to move
            Debug("Nothing to move. Stop.")
            return
        end
    -- Can occur if an addon has destroyed our item while we were restacking
    elseif errorCode == GUILD_BANK_TRANSFER_PENDING then
        
        -- Retry to move the stack
        
        waitingRetries = waitingRetries + 1
        if waitingRetries < 10 then
            UI:GetNamedChild("Description"):SetText("Guild bank busy, trying to return restacked " .. cSlot.name .. " to the Guild Bank again")
            Debug("zo_callLater(ReturnItemsToBank, " .. tostring(DELAY * 5) .. "), slotIndex=" .. tostring(slotIndex) .. ", itemIndex=" .. tostring(itemIndex) .. ", waitingRetries=" .. tostring(waitingRetries))
            zo_callLater(ReturnItemsToBank, DELAY * 5) -- Should be long, Guild Bank can be busy for 3-5s quite often
        else
            StopGBRestackAndRestartScan()
        end
    elseif SHARED_INVENTORY:GenerateSingleSlotData(lastRestackResult[itemIndex][slotIndex].bagId, lastRestackResult[itemIndex][slotIndex].slotId) then
        UI:GetNamedChild("Description"):SetText("Returning restacked " .. cSlot.name .. " to the Guild Bank")
        TransferToGuildBank(lastRestackResult[itemIndex][slotIndex].bagId, lastRestackResult[itemIndex][slotIndex].slotId)
        Debug("TransferToGuildBank(" .. tostring(lastRestackResult[itemIndex][slotIndex].bagId) .. ", " .. tostring(lastRestackResult[itemIndex][slotIndex].slotId) .. ")")
        -- It will trigger .BankItemsReceived because of EVENT_GUILD_BANK_ITEM_ADDED
        -- It will trigger ReturnItemsToBank if an error has occured
    -- Another error
    elseif errorCode then
        Debug("No error code. Stop.")
        -- Not handled yet, stop
        return
    else
        -- It's a 3rd party addon push while we were restacking, or item has been destroyed
        Debug("Third party addon, or item destroyed. RestackGuildbank().")
        self.RestackGuildbank()
    end
    
end

local function RestackStackableBag(bagId, duplicateList)
    
    local result = {}
    local indexItemsDuplicated, dataItems = next(duplicateList)
    Debug("RestackStackableBag(" .. tostring(bagId) .. ", " .. tostring(duplicateList) .. ")")
    
    if bagId == BAG_BACKPACK then

        -- Loop for item X/Y/Z
        while indexItemsDuplicated do
            
            local index = 1
            local itemInfo = dataItems[index]
            local baseSlot = nil
            local lastMoveWasSingleStack = false
            local lastMoveWasMultiStack = false
            result[indexItemsDuplicated] = {}
            
            -- Loop for item X and slots 1/2/3/y
            while itemInfo do
                
                -- 1st loop : we go in
                if not baseSlot then
                    -- Our actual stack / Our max size
                    baseSlot = itemInfo
                    baseSlot.actualStack, baseSlot.maxStack = GetRealSlotStackSize(bagId, itemInfo.slotId)
                else
                    
                    local qty
                    -- If stacking, will we get 1 or 2 stacks ?
                    itemInfo.maxStack = baseSlot.maxStack
                    
                    if (baseSlot.actualStack + itemInfo.stack) <= baseSlot.maxStack then
                        
                        -- Only 1 stack, we can merge stacks
                        qty = itemInfo.stack
                        
                        -- Merging
                        if IsProtectedFunction("RequestMoveItem") then
                            Debug("CallSecureProtected(\"RequestMoveItem\", " .. tostring(bagId) .. ", " .. tostring(itemInfo.slotId) .. ", " .. tostring(bagId) .. ", " .. tostring(baseSlot.slotId) .. ", " .. tostring(qty) .. ")")
                            CallSecureProtected("RequestMoveItem", bagId, itemInfo.slotId, bagId, baseSlot.slotId, qty)
                        else
                            Debug("RequestMoveItem(" .. tostring(bagId) .. ", " .. tostring(itemInfo.slotId) .. ", " .. tostring(bagId) .. ", " .. tostring(baseSlot.slotId) .. ", " .. tostring(qty) .. ")")
                            RequestMoveItem(bagId, itemInfo.slotId, bagId, baseSlot.slotId, qty)
                        end
                        
                        -- Update values baseSlot can still be used in next loop
                        baseSlot.actualStack = baseSlot.actualStack + itemInfo.stack
                        baseSlot.stack = baseSlot.actualStack
                        
                        -- 05/07/2026 performance improvement: this branch runs once per
                        -- duplicate-stack pair being merged and used to index into
                        -- result[indexItemsDuplicated] and recompute #result[indexItemsDuplicated]
                        -- up to 8 times combined. The length operator isn't guaranteed O(1) in
                        -- Lua, and the table it's read from doesn't change between those repeated
                        -- reads, so cache the list reference and its length once per branch instead.
                        if lastMoveWasMultiStack == true then
                            result[indexItemsDuplicated][#result[indexItemsDuplicated]] = baseSlot
                            lastMoveWasSingleStack = true
                            lastMoveWasMultiStack = false
                        elseif lastMoveWasSingleStack == true then
                            result[indexItemsDuplicated][#result[indexItemsDuplicated]] = baseSlot
                            lastMoveWasMultiStack = false
                        else
                            table.insert(result[indexItemsDuplicated], baseSlot)
                            lastMoveWasSingleStack = true
                            lastMoveWasMultiStack = false
                        end
                        
                    else
                        
                        -- It won't fit, just move the qty to match maxStack, no need to rescan because slots don't move, only stacks.
                        qty = baseSlot.maxStack - baseSlot.actualStack
                        
                        -- Merging
                        if IsProtectedFunction("RequestMoveItem") then
                            Debug("CallSecureProtected(\"RequestMoveItem\", " .. tostring(bagId) .. ", " .. tostring(itemInfo.slotId) .. ", " .. tostring(bagId) .. ", " .. tostring(baseSlot.slotId) .. ", " .. tostring(qty) .. ")")
                            CallSecureProtected("RequestMoveItem", bagId, itemInfo.slotId, bagId, baseSlot.slotId, qty)
                        else
                            Debug("RequestMoveItem(" .. tostring(bagId) .. ", " .. tostring(itemInfo.slotId) .. ", " .. tostring(bagId) .. ", " .. tostring(baseSlot.slotId) .. ", " .. tostring(qty) .. ")")
                            RequestMoveItem(bagId, itemInfo.slotId, bagId, baseSlot.slotId, qty)
                        end
                        
                        local list = result[indexItemsDuplicated]

                        if lastMoveWasMultiStack == true then
                            local lastIdx = #list
                            list[lastIdx].stack = baseSlot.maxStack
                            list[lastIdx].actualStack = baseSlot.maxStack
                            table.insert(list, itemInfo)
                            lastIdx = lastIdx + 1
                            list[lastIdx].stack = itemInfo.stack - qty
                            list[lastIdx].actualStack = itemInfo.stack - qty
                            lastMoveWasSingleStack = false
                        elseif lastMoveWasSingleStack == true then
                            local lastIdx = #list
                            list[lastIdx].stack = baseSlot.maxStack
                            list[lastIdx].actualStack = baseSlot.maxStack
                            table.insert(list, itemInfo)
                            lastIdx = lastIdx + 1
                            list[lastIdx].stack = itemInfo.stack - qty
                            list[lastIdx].actualStack = itemInfo.stack - qty
                            lastMoveWasSingleStack = false
                            lastMoveWasMultiStack = true
                        else
                            table.insert(list, baseSlot)
                            local lastIdx = #list
                            list[lastIdx].stack = baseSlot.maxStack
                            list[lastIdx].actualStack = baseSlot.maxStack
                            table.insert(list, itemInfo)
                            lastIdx = lastIdx + 1
                            list[lastIdx].stack = itemInfo.stack - qty
                            list[lastIdx].actualStack = itemInfo.stack - qty
                            lastMoveWasSingleStack = false
                            lastMoveWasMultiStack = true
                        end
                        
                        -- Baseslot is now at max, we cannot use it anymore
                        baseSlot = itemInfo
                        baseSlot.actualStack = itemInfo.stack - qty
                        
                    end
                    
                end
                
                index = index + 1
                itemInfo = dataItems[index]
            
            end
            
            -- 05/07/2026 bugfix: this used to advance with an independent counter
            -- (`itemIndex = itemIndex + 1; next(duplicateList, itemIndex)`) instead of the
            -- actual previous key returned by next(). That only "worked" because the sole
            -- caller always passes a freshly built array with sequential integer keys
            -- (1, 2, 3...), which happens to line up with the counter. If this were ever
            -- called with a hash-keyed table (e.g. the main `duplicates` table, keyed by
            -- item instance IDs) instead, `next()` would receive a key that doesn't exist
            -- in the table and Lua would raise "invalid key to 'next'", crashing the
            -- restack mid-run. Using the real key removes that landmine entirely.
            indexItemsDuplicated, dataItems = next(duplicateList, indexItemsDuplicated)
            
        end
    elseif bagId == BAG_VIRTUAL then
        
        result = {
            [1] = {}
        }
        
        local stack, maxStack = GetRealSlotStackSize(bagId, dataItems[1].slotId)
        local qtyToPush = qtyToMoveToGuildBank
        
        local pushBack = true
        while pushBack do
            
            local qtyToWrite
            if qtyToPush > maxStack then
                qtyToWrite = maxStack
                qtyToPush = qtyToPush - maxStack
            else
                qtyToWrite = qtyToPush
                pushBack = false
            end
            
            table.insert(result[1], {itemInstanceId = dataItems[1].itemInstanceId, slotId = dataItems[1].slotId, bagId = bagId, stack = qtyToWrite, texture = dataItems[1].texture, name = dataItems[1].name})
            
        end
        
    end
    
    return result
    
end

-- Triggers when EVENT_GUILD_BANK_ITEM_ADDED
local function OnGuildBankItemAdded(_, gslot, localPlayer)
    if not localPlayer then return end -- avoid triggering when other players add items in Guild Bank
	
    local self = addon
    Debug("OnGuildBankItemAdded(_, " .. tostring(gslot) .. ")")

    
    -- Roomba is restacking the guild bank
    -- Is the item added our last move ?
    -- Get its instanceID
    local id = GetItemInstanceId(BAG_GUILDBANK, gslot)
	
	local LRR = lastRestackResult[itemIndex] or 0 -- roomba lite
	if LRR ~= 0 then LRR = lastRestackResult[itemIndex][slotIndex] or 0 end
	if LRR ~= 0 then LRR = lastRestackResult[itemIndex][slotIndex].itemInstanceId or 0 end
    
    -- Protection
    if id ~= LRR then 
 	
		
		if db.liteMode then -- roomba Lite
		    liteModeGslot = gslot
		    registerThisItem() 

		end
	return 
	end
    
    --If we're here that's because it's our Roomba item which was sent in GuildBank
    -- Let's move the next stack
    -- Let's try next try of the same item. Is there another stack to move?
    
    if next(lastRestackResult[itemIndex], slotIndex) then
        -- yes, try to move it
        qtyToMoveToGuildBank = qtyToMoveToGuildBank - lastRestackResult[itemIndex][slotIndex].stack
        slotIndex = slotIndex + 1
        Debug("zo_callLater(ReturnItemsToBank, " .. tostring(DELAY) .. "), slotIndex=1, itemIndex=" .. tostring(itemIndex))
        zo_callLater(ReturnItemsToBank, DELAY)
        
    -- No more stack. Maybe another item? - Should not happen , because there is only 1 item in .lastRestackResult, the others items are in duplicates
    elseif next(lastRestackResult, itemIndex) then
    
        -- Yes, move its first stack
        itemIndex = itemIndex + 1
        slotIndex = 1
        qtyToMoveToGuildBank = 0
        Debug("zo_callLater(ReturnItemsToBank, " .. tostring(DELAY) .. "), slotIndex=1, itemIndex=" .. tostring(itemIndex))
        zo_callLater(ReturnItemsToBank, DELAY)
        
    else

        -- Nothing else to move for this item, let's do the rest
        qtyToMoveToGuildBank = 0
        Debug("RestackGuildbank()")
        self.RestackGuildbank()
    end
    
end

-- Triggers when EVENT_INVENTORY_SINGLE_SLOT_UPDATE
local function ReceiveItemInBagpack(_, bagId, slotId, _, _, _, stackCountChange)
    
    local self = addon
    Debug("ReceiveItemInBagpack(_, " .. tostring(bagId) .. ", " .. tostring(slotId) .. ", _, _, _, " .. tostring(stackCountChange) .. ")")
    
    -- Protection
    if (bagId == BAG_BACKPACK or bagId == BAG_VIRTUAL) and cItemDuplicateList then
    
        local id = GetItemInstanceId(bagId, slotId)
        
        -- Is slot really used?
        if not id then return end
        
        -- Is slot == our item transferred, avoid manual transfers interfer while we restack
        if id ~= cSlot.itemInstanceId then return end
        
        -- Set in wich bag/slot our stack is
        cSlot.bagId = bagId
        cSlot.slotId = slotId
        qtyToMoveToGuildBank = qtyToMoveToGuildBank + cSlot.stack
        
        -- Build an array for merging in backpack
        table.insert(inBagCollection, cSlot)
        
        -- If we have another slot to move from GuildBank
        if next(cItemDuplicateList, cSlotIdx) then
            
            cSlotIdx, cSlot = next(cItemDuplicateList, cSlotIdx)
            
            local duplicateId = GetItemInstanceId(BAG_GUILDBANK, cSlot.slotId)
            
            -- Is slot really used?
            if not duplicateId then
                StopGBRestackAndRestartScan()
                return
            end
            
            -- Is slot == our item transferred, avoid manual transfers interfer while we restack
            if duplicateId ~= cSlot.itemInstanceId then
                StopGBRestackAndRestartScan()
                return
            end
            
            -- The TransferFromGuildBank will execute ReceiveItemInBagpack because of registration
            Debug("TransferFromGuildBank(" .. tostring(cSlot.slotId) .. ")")
            TransferFromGuildBank(cSlot.slotId)
            
        else
            
            -- No more slots to move, let's stack them
            -- Disable ReceiveItemInBagpack, we've finished to transfer all stacks of same item
            EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
            
            UI:GetNamedChild("Description"):SetText("Stacking " .. cSlot.name .. " in inventory")
            
            -- restack items Add an array up to our array to cheat
            lastRestackResult = RestackStackableBag(bagId, {inBagCollection})
            
            -- These events will loop the move back to the guild bank
            -- This event is only here to "retry" if a return has fail
            EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_TRANSFER_ERROR, ReturnItemsToBank)
            -- This event will triger the next transfer to bagpack?
            EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded)
            
            -- This one is mandatory due to lags of SHARED_INVENTORY:GenerateFullSlotData
            Debug("zo_callLater(function() { ... }, " .. tostring(DELAY) .. ")")
            zo_callLater(function()
            
                --Init
                itemIndex = 1
                slotIndex = 1
                
                -- No errors, is our item here ?
                
                if lastRestackResult[itemIndex][slotIndex] and SHARED_INVENTORY:GenerateSingleSlotData(bagId, lastRestackResult[itemIndex][slotIndex].slotId) and UI and UI:GetNamedChild("Description") and cSlot then
                    UI:GetNamedChild("Description"):SetText("Returning restacked " .. cSlot.name .. " to the Guild Bank")
                    Debug("TransferToGuildBank(" .. tostring(bagId) .. ", " .. tostring(lastRestackResult[itemIndex][slotIndex].slotId) .. ")")
                    TransferToGuildBank(bagId, lastRestackResult[itemIndex][slotIndex].slotId)
                    -- It will trigger OnGuildBankItemAdded because of EVENT_GUILD_BANK_ITEM_ADDED
                    -- It will trigger ReturnItemsToBank if an error has occured
                end
            end, DELAY)
            
        end
    end
    
end

-- Restack the bank. This function is voluntary leaked to global due to an internal loop in the addon code
function addon.RestackGuildbank()
    
    local self = addon
    Debug("RestackGuildbank()")

    -- Protect
    if (not checkingBank) then return end
    
    -- 5 slots Needed to Work
    if not CheckInventorySpaceAndWarn(5) then return end
    
    -- Resetted after each restack / each bank swap
    if not cInstanceId then
        checkingBank = false
        RoombaReady()
        checkingBank = true
    end
    
    -- Pull the next job off the stack
    cInstanceId, cItemDuplicateList = next(duplicates, cInstanceId)
    
    -- Protect against Keybind
    if cInstanceId then
        currentRun[cInstanceId] = true
        processedCount = processedCount + 1 -- 05/07/2026 performance improvement, see below
    end
    
    qtyToMoveToGuildBank = 0
    
    -- They are some duplicates .cItemDuplicateList is an array of multiple stacks of same item
    if cItemDuplicateList then
        
        -- Flag for other addons
        restackInProgress = true
        
        -- Show progress Bar, etc.
        -- 05/07/2026 performance improvement:
        -- RestackGuildbank runs once per duplicate item group being restacked, and for a
        -- guild bank/backpack with many duplicate stacks this can fire dozens or hundreds
        -- of times per run. It used to call NonContiguousCount(currentRun) and
        -- NonContiguousCount(duplicates) every single time just to feed the progress bar -
        -- both walk the ENTIRE table with pairs() to count entries, turning an O(n) restack
        -- loop into an O(n^2) one purely for a progress percentage. `duplicates` doesn't
        -- change size during a run at all, and `currentRun` only ever grows by exactly one
        -- entry per call, so both counts are cheap to track incrementally instead:
        -- duplicatesTotal is computed once when the scan finishes, and processedCount is
        -- bumped by 1 right above instead of being recounted from scratch.
        UI:SetHidden(false)
        local index = processedCount
        local total = duplicatesTotal
        ZO_StatusBar_SmoothTransition(UI:GetNamedChild("SpeedRow").bar, index , total, true)
        UI:GetNamedChild("SpeedRow").value:SetText(string.format("%3d", (index / total) * 100) .. "%")
        UI:GetNamedChild("SpeedRow").value:SetWidth(90)
        UI:GetNamedChild("SpeedRow").value:SetHidden(false)
        
        -- Init
        cSlotIdx = 1
        
        -- 1st stack
        cSlot = cItemDuplicateList[cSlotIdx]
        
        -- cSlot is the slot to get from GuildBank
        UI:GetNamedChild("Icon"):SetTexture(cSlot.texture)
        
        -- Init what's actually in our bagpack
        inBagCollection = {}
        
        -- If it suddenly doesn't exist, try the next in the list (can be caused by addons which autodestroy or other transfering utilities).
        if not SHARED_INVENTORY:GenerateSingleSlotData(BAG_GUILDBANK, cSlot.slotId) then zo_callLater(self.RestackGuildbank, DELAY) end
        
        -- Will trigger the function when TransferFromGuildBank will be executed
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ReceiveItemInBagpack)
        
        UI:GetNamedChild("Description"):SetText("Retrieving " .. cSlot.name .. " from Guild Bank")
        
        -- Take a stack from bank, it will trigger ReceiveItemInBagpack
        Debug("TransferFromGuildBank(" .. tostring(cSlot.slotId) .. ")")
        TransferFromGuildBank(cSlot.slotId)
        
    else
         StopGBRestackAndRestartScan() 
    end
    
end

local function BagNeedRestack(sceneName)

    -- Protect
    -- 05/07/2026 performance improvement: accept an already-resolved scene name from the
    -- caller (e.g. the per-frame keybind visibility callback below) instead of always
    -- asking SCENE_MANAGER for the current scene ourselves. See UpdateAndDisplayKeybind
    -- for why this matters.
    if sceneName == nil and SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
        sceneName = SCENE_MANAGER:GetCurrentScene():GetName()
    end

    if sceneName and not (sceneName == "guildBank" or sceneName == "gamepad_guild_bank") then
        return false
    end
    
    if #duplicates >= 1 then
        return true
    end

end

local function BeginStackingProcess()

    local self = addon

    -- 05/07/2026 performance improvement: SCENE_MANAGER:GetCurrentScene():GetName() was
    -- called twice here (once per side of the "or"). It's a single fixed value for the
    -- duration of this call, so resolve it once and reuse it.
    local sceneName = SCENE_MANAGER:GetCurrentScene():GetName()

    -- What function to use ? depends on the scene
    if (sceneName == "guildBank" or sceneName == "gamepad_guild_bank") and db.RoombaAtGBank then
        -- Rescan first
        RoombaReady()
        -- Restack GuildBank
        self.RestackGuildbank()
    end

end

-- For Compatibility, can be called by other addons
addon.BeginStackingProcess = BeginStackingProcess

local function BeginScanningProcess()

    -- 05/07/2026 performance improvement: same fix as BeginStackingProcess above - resolve
    -- the scene name once instead of calling GetCurrentScene():GetName() twice.
    local sceneName = SCENE_MANAGER:GetCurrentScene():GetName()

    if (sceneName == "guildBank" or sceneName == "gamepad_guild_bank") and db.RoombaAtGBank then
        RoombaReady()
    end
    
end

local function SelectGuildBank(_, guildBankId)
    
    -- Reset flag for bank switch
    checkingBank = false
    currentBank = guildBankId
    StopStackingProcess()
    
end

local function OnGuildBankReallyReady()
    Debug("OnGuildBankReallyReady()")

    -- Limit calls to RoombaReady()
    if not checkingBank then
        
        if IsInGamepadPreferredMode() then
            UI = RoombaWindowGamepad
        else
            UI = RoombaWindow
        end
        
        checkingBank = true
        RoombaReady()
    end
    
end

local function OnGuildBankReady()
    -- Guild bank is evented to be ready, but wait a short while before processing. (multiple readys for big banks ~3/4)
    zo_callLater(function() OnGuildBankReallyReady() end, 1700)
end

local function OnCloseGuildBank()
  
    local self = addon
  
    if db.RoombaAtGBank then
	
        if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor) 
        end
        
        if UI then
            UI:SetHidden(true)
        end
        
        StopStackingProcess()
        
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_SELECTED)        
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_ITEM_ADDED)
        checkingBank = false
        
    end
end

local function OnOpenGuildBank()
    local self = addon
    if db.RoombaAtGBank then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY, OnGuildBankReady)
        -- Clear the flag when swapping banks
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_SELECTED, SelectGuildBank)
		
		if db.liteMode then EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded) end -- roomba Lite
    end
end

local function UpdateAndDisplayKeybind()

    -- We can't "really" update a keybind name dynamically while using "name = function() .. end" so we use the "visible" one.

    -- 05/07/2026 performance improvement:
    -- This function is the keybind's "visible" callback, which ZOS's KEYBIND_STRIP
    -- evaluates every frame the strip is active - by far the hottest path in the whole
    -- addon, far hotter than the scan/restack functions optimized earlier. As written it
    -- called SCENE_MANAGER:GetCurrentScene():GetName() up to 4 times per invocation: once
    -- inside the else-branch below, once more at the end, and twice again inside
    -- BagNeedRestack() (once per side of its "or" check). Each of those is a userdata
    -- method dispatch plus a string return for a value that cannot change within a single
    -- call - so it was wasted work, repeated every frame. Fix: resolve the scene name ONCE
    -- and reuse it for every check below, including handing it to BagNeedRestack() so it
    -- doesn't look it up again itself.
    local sceneName
    if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
        sceneName = SCENE_MANAGER:GetCurrentScene():GetName()
    end

	if Roomba.WorkInProgress() then
	    descriptorName = GetString(ROOMBA_STOP) 
    elseif BagNeedRestack(sceneName) then
        descriptorName = GetString(SI_BINDING_NAME_RUN_ROOMBA) 
    elseif sceneName == "guildBank" or sceneName == "gamepad_guild_bank" then
        descriptorName = GetString(ROOMBA_RESCAN_BANK)
    end

    return sceneName == "guildBank" or sceneName == "gamepad_guild_bank"

end

-- 05/07/2026 bugfix: previously this table was built ONCE, here, at addon load, with the
-- button entry hardcoded at key [keyBindIndex] using whatever keyBindIndex was AT THAT
-- MOMENT (always 1, its initial default - RoombaReady hadn't run yet). Later, RoombaReady
-- would set keyBindIndex = 2 as a fallback when slot 1 was already taken by another
-- addon's keybind, but since keybindDescriptor was never rebuilt, that assignment did
-- nothing - the button always ended up at [1] regardless. Making this a function that
-- (re)builds keybindDescriptor from the CURRENT keyBindIndex, called again whenever
-- keyBindIndex changes, makes the fallback actually take effect.
function BuildKeybindDescriptor()
    keybindDescriptor = { 
        alignment = db.RoombaPosition,
        [keyBindIndex] = {
            name = function() return descriptorName end,
            keybind = IsConsoleUI() and "UI_SHORTCUT_SECONDARY" or "RUN_ROOMBA", 
            control = IsInGamepadPreferredMode() and RoombaWindowGamepad or RoombaWindow,
            callback = Roomba_StartRoomba, 
            visible = UpdateAndDisplayKeybind, 
            icon = [[Roomba\media\RoombaSearch.dds]],
        },
    }
end

local function InitializeKeybind()
    BuildKeybindDescriptor()
end

local function InitializeSpeedRow(control)
    
    control:SetDrawLayer(DL_OVERLAY)
    control:GetNamedChild("SpeedRow").value:SetText(" 0%")
    
    ZO_StatusBar_SetGradientColor(control:GetNamedChild("SpeedRow").bar, ZO_XP_BAR_GRADIENT_COLORS)
    ZO_StatusBar_SmoothTransition(control:GetNamedChild("SpeedRow").bar, 0, 20, true)
    
    control:GetNamedChild("SpeedRow"):GetNamedChild("Icon"):SetHidden(true)
    control:GetNamedChild("SpeedRow"):GetNamedChild("BarContainer"):ClearAnchors()
    control:GetNamedChild("SpeedRow"):GetNamedChild("BarContainer"):SetAnchor(BOTTOM, control:GetNamedChild("Icon"), BOTTOM, 30, 70)
    
    control:GetNamedChild("SpeedRow").value:SetFont("ZoFontHeader3")
    
end

local function InitialiseSettings()

    local self = addon

    -- Fetch the saved variables
    db = LibSavedVars:NewAccountWide(self.name .. "_Account", defaults)
                     :AddCharacterSettingsToggle(self.name .. "_Character")
    
    if LSV_Data.EnableDefaultsTrimming then
        db:EnableDefaultsTrimming()
    end
    
    if db.RoombaPosition == KEYBIND_STRIP_ALIGN_LEFT then
        keybindCheck = "leftButtons"
    elseif db.RoombaPosition == KEYBIND_STRIP_ALIGN_RIGHT then
        keybindCheck = "rightButtons"
    elseif db.RoombaPosition == KEYBIND_STRIP_ALIGN_CENTER then
        keybindCheck = "centerButtons"
    end
    
    local panelData = {
        type = "panel",
        name = self.name,
        displayName = self.name,
        author = self.author,
        version = self.version,
        slashCommand = "/roomba",
        registerForRefresh = true,
        registerForDefaults = true,
        website = self.website,
    }
    
    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("RoombaOptions", panelData)
    
    local optionsTable = {
        
        -- Account-wide settings
        db:GetLibAddonMenuAccountCheckbox(),
        
        {
            type = "checkbox",
            name = GetString(ROOMBA_GBANK),
            tooltip = GetString(ROOMBA_GBANK_TOOLTIP),
            getFunc = function() return db.RoombaAtGBank end,
            setFunc = function(newValue) db.RoombaAtGBank = newValue end,
            default = defaults.RoombaAtGBank,
        },
        {
            type = "checkbox",
            name = GetString(ROOMBA_LITEMODE),
            tooltip = GetString(ROOMBA_LITEMODE_TOOLTIP),
            getFunc = function() return db.liteMode end,
            setFunc = function(newValue) db.liteMode = newValue end,
            default = defaults.liteMode,
        },
        {
            type = "dropdown",
            name = GetString(ROOMBA_POSITION),
            tooltip = GetString(ROOMBA_POSITION_TOOLTIP),
            choices = {
                GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_LEFT),
                GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_CENTER),
                GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_RIGHT),
            },
            default = defaults.RoombaPosition,
            warning = GetString(SI_ADDON_MANAGER_RELOAD),
            getFunc = function() return GetString("ROOMBA_POSITION_CHOICE", db.RoombaPosition) end,
            setFunc = function(choice)
                if choice == GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_LEFT) then
                    db.RoombaPosition = KEYBIND_STRIP_ALIGN_LEFT
                    keybindCheck = "leftButtons"
                elseif choice == GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_RIGHT) then
                    db.RoombaPosition = KEYBIND_STRIP_ALIGN_RIGHT
                    keybindCheck = "rightButtons"
                elseif choice == GetString("ROOMBA_POSITION_CHOICE", KEYBIND_STRIP_ALIGN_CENTER) then
                    db.RoombaPosition = KEYBIND_STRIP_ALIGN_CENTER
                    keybindCheck = "centerButtons"
                elseif IsInGamepadPreferredMode() then
                    -- When user click on LAM reinit button
                    db.RoombaPosition = defaults.RoombaPosition
                    keybindCheck = "centerButtons"
                else
                -- When user click on LAM reinit button
                    db.RoombaPosition = defaults.RoombaPosition
                    keybindCheck = "leftButtons"
                end
                
                if IsConsoleUI() then
                    -- Delay slightly so the gamepad settings menu can close cleanly before reload.
                    zo_callLater(function() ReloadUI() end, 250)
                else
                    ReloadUI()
                end
                
            end,
        },
    }
    
    LAM:RegisterOptionControls("RoombaOptions", optionsTable)
    
end

-- Called by Bindings
function Roomba_StartRoomba()
    if Roomba.WorkInProgress() then -- stop stacking if called again
        StopGBRestackAndRestartScan()
        return
    end
    if BagNeedRestack() then
        BeginStackingProcess()
    else
        BeginScanningProcess()
    end
end

-- Don't spam this function, GetNumBagFreeSlots & FindFirstEmptySlotInBag are slow to update (wait for Guild Bank event before using it twice)
-- This function accept qtyToMoveToGuildBank leaked to local or global namespace.
-- It's the qty to move from BAG_VIRTUAL. if not provided, math.min(stackCount, maxStack) is pushed
local function PreHookTransferToGuildBank()

    -- Bug sometimes, so let's use the backpack for every move
    local original_TransferToGuildBank = TransferToGuildBank
    local function TransferToGuildBankByBackpack(sourceBag, slotIndex)
      
        if IsGuildBankOpen() and sourceBag == BAG_VIRTUAL then
            Debug("TransferToGuildBankByBackpack(" .. tostring(sourceBag) .. ", " .. tostring(slotIndex) .. ")")
            if GetNumBagFreeSlots(BAG_BACKPACK) >= 1 and GetNumBagFreeSlots(BAG_GUILDBANK) >= 1 then
                local proxySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
                local stack, maxStack = GetRealSlotStackSize(sourceBag, slotIndex)
                local qtyTuPush = qtyToMoveToGuildBank or 0 -- Var can be nil
                qtyTuPush = math.min(stack, maxStack, qtyTuPush) -- qtyToMoveToGuildBank > maxStack too. Avoid this.
                
                if IsProtectedFunction("RequestMoveItem") then
                    Debug("CallSecureProtected(\"RequestMoveItem\", " .. tostring(sourceBag) .. ", " .. tostring(slotIndex) .. ", " .. tostring(BAG_BACKPACK) .. ", " .. tostring(proxySlot) .. ", " .. tostring(qtyTuPush) .. ")")
                    CallSecureProtected("RequestMoveItem", sourceBag, slotIndex, BAG_BACKPACK, proxySlot, qtyTuPush)
                else
                    Debug("RequestMoveItem(" .. tostring(sourceBag) .. ", " .. tostring(slotIndex) .. ", " .. tostring(BAG_BACKPACK) .. ", " .. tostring(proxySlot) .. ", " .. tostring(qtyTuPush) .. ")")
                    RequestMoveItem(sourceBag, slotIndex, BAG_BACKPACK, proxySlot, qtyTuPush)
                end
                
                original_TransferToGuildBank(BAG_BACKPACK, proxySlot)
                
                return true
            
            end
        end
    end

    ZO_PreHook("TransferToGuildBank", TransferToGuildBankByBackpack)
	
end

local function OnAddonLoaded(_, addOnName)
    
    local self = addon
    
    if addOnName == self.name then
    
        if IsInGamepadPreferredMode() then
            defaults.RoombaPosition = KEYBIND_STRIP_ALIGN_CENTER
        end
		
        ZO_CreateStringId("SI_BINDING_NAME_RUN_ROOMBA", descriptorName)
        
        -- RoombaWindow is the keyboard-UI window and is never shown on console.
        if not IsConsoleUI() then
            InitializeSpeedRow(RoombaWindow)
        end
        InitializeSpeedRow(RoombaWindowGamepad)

        if IsConsoleUI() then
            RoombaWindowGamepad:GetNamedChild("Description"):SetFont("$(MEDIUM_FONT)|18|soft-shadow-thin")
        end
        
        InitialiseSettings()
        InitializeKeybind()
        
        PreHookTransferToGuildBank()
		
		ZO_PreHook("PlayItemSound",
			function(_, itemSoundAction)
				if Roomba.WorkInProgress() then
				    -- update button to display "stop"
				    if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
                       KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
                    end
					PlaySound(SOUNDS.SPINNER_UP)
					return itemSoundAction == ITEM_SOUND_ACTION_SLOT 
				end
			end
		)
        
        -- Set the function to run when guild bank is opened (before guild bank is ready)
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_GUILD_BANK, OnOpenGuildBank)
        
        -- Set the function to run when guild bank is closed
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_GUILD_BANK, OnCloseGuildBank)
		
		
    end
    
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)