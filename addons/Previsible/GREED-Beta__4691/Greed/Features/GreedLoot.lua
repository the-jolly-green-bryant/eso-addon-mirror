Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local GreedData = Greed_Addon.Data
local libSets = Internal.libSets
local T = Internal.T
local DROP_LOG_MAX_ENTRIES = Internal.DROP_LOG_MAX_ENTRIES
local DROP_LOG_MAX_VISIBLE_ROWS = Internal.DROP_LOG_MAX_VISIBLE_ROWS
local DEFAULT_DROP_ASK_MESSAGE = Internal.DEFAULT_DROP_ASK_MESSAGE
local DROP_LOG_TEXT_SIZES = Internal.DROP_LOG_TEXT_SIZES
local DEFAULT_FONT_NAME = Internal.DEFAULT_FONT_NAME
local FONT_OPTION_BY_LABEL = Internal.FONT_OPTION_BY_LABEL
local FONT_CHOICE_LABELS = Internal.FONT_CHOICE_LABELS
local WEAPON_ITEMS = Internal.WEAPON_ITEMS
local WEAPON_ITEM_BY_KEY = Internal.WEAPON_ITEM_BY_KEY
local MONSTER_ARMOR_SLOT_KEYS = Internal.MONSTER_ARMOR_SLOT_KEYS
local SafeAnnounce = Internal.SafeAnnounce
local TrimText = Internal.TrimText

local GREED_TRADE_CHAT_MAX_CHARS = 300
local GREED_TRADE_ACTIVITY_RECHECK_DELAY_MS = 500
local GREED_TRADE_LOOT_MATCH_WINDOW_MS = 8000
local GREED_TRADE_RECENT_SLOT_MAX = 24
local GREED_TRADE_PENDING_LOOT_MAX = 40

local function GetGreedTradeNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, now = pcall(GetFrameTimeMilliseconds)
        if ok and type(now) == "number" then return now end
    end

    if type(GetTimeStamp) == "function" then
        local ok, now = pcall(GetTimeStamp)
        if ok and type(now) == "number" then return now * 1000 end
    end

    return 0
end

function Greed:GetTradeLootSession()
    if type(self.tradeLootSession) ~= "table" then
        self.tradeLootSession = {
            state = "none",
            generation = 0,
            itemsByUniqueId = {},
            orderedUniqueIds = {},
            pendingLoot = {},
            recentSlots = {},
            validationDirty = true,
            preparedBatches = nil,
            preparedBatchIndex = 0,
        }
    end

    return self.tradeLootSession
end

function Greed:ClearTradeLootPreparedBatches()
    local session = self:GetTradeLootSession()
    session.preparedBatches = nil
    session.preparedBatchIndex = 0
    session.validationDirty = true
end

function Greed:ResetTradeLootSession()
    self.tradeLootSession = nil
    self.tradeLootActivityCheckToken = nil
    self:GetTradeLootSession()
end

function Greed:IsTradeLootGroupAvailable()
    if type(IsUnitGrouped) == "function" then
        local ok, grouped = pcall(function()
            return IsUnitGrouped("player")
        end)
        if ok and grouped == true then return true end
    end

    if type(GetGroupSize) == "function" then
        local ok, groupSize = pcall(GetGroupSize)
        if ok and type(groupSize) == "number" and groupSize > 1 then return true end
    end

    return false
end

function Greed:HasTradeLootValidationApis()
    return type(GetItemUniqueId) == "function"
        and type(IsItemBoPAndTradeable) == "function"
        and type(GetItemBoPTimeRemainingSeconds) == "function"
end

function Greed:GetCurrentTradeActivityIdentity()
    if not self:IsTradeLootGroupAvailable() then return nil end
    if type(GetCurrentZoneDungeonDifficulty) ~= "function" then return nil end

    local okDifficulty, difficulty = pcall(GetCurrentZoneDungeonDifficulty)
    local noneDifficulty = DUNGEON_DIFFICULTY_NONE or 0
    if not okDifficulty or type(difficulty) ~= "number" or difficulty <= noneDifficulty then
        return nil
    end

    if type(IsInstanceEndlessDungeon) == "function" then
        local okEndless, endless = pcall(IsInstanceEndlessDungeon)
        if okEndless and endless == true then return nil end
    end

    local zoneId
    if type(GetUnitZoneIndex) == "function" and type(GetZoneId) == "function" then
        local okZone, resolvedZoneId = pcall(function()
            return GetZoneId(GetUnitZoneIndex("player"))
        end)
        if okZone and type(resolvedZoneId) == "number" and resolvedZoneId > 0 then
            zoneId = resolvedZoneId
        end
    end
    if not zoneId and type(GetUnitWorldPosition) == "function" then
        local okWorld, resolvedZoneId = pcall(function()
            return GetUnitWorldPosition("player")
        end)
        if okWorld and type(resolvedZoneId) == "number" and resolvedZoneId > 0 then
            zoneId = resolvedZoneId
        end
    end
    if not zoneId then return nil end

    local parentZoneId = zoneId
    if type(GetParentZoneId) == "function" then
        local okParent, resolvedParentZoneId = pcall(GetParentZoneId, zoneId)
        if okParent and type(resolvedParentZoneId) == "number" and resolvedParentZoneId > 0 then
            parentZoneId = resolvedParentZoneId
        end
    end

    local mapId = 0
    if type(GetCurrentMapId) == "function" then
        local okMap, resolvedMapId = pcall(GetCurrentMapId)
        if okMap and type(resolvedMapId) == "number" then
            mapId = resolvedMapId
        end
    end

    local raidId = 0
    if type(GetCurrentParticipatingRaidId) == "function" then
        local okRaid, resolvedRaidId = pcall(GetCurrentParticipatingRaidId)
        if okRaid and type(resolvedRaidId) == "number" then
            raidId = resolvedRaidId
        end
    end

    local reviveCounter
    if type(GetCurrentRaidStartingReviveCounters) == "function" then
        local okRevives, resolvedRevives = pcall(GetCurrentRaidStartingReviveCounters)
        if okRevives and type(resolvedRevives) == "number" then
            reviveCounter = resolvedRevives
        end
    end

    local reviveCounterRaid = false
    if type(IsPlayerInReviveCounterRaid) == "function" then
        local okReviveRaid, inReviveRaid = pcall(IsPlayerInReviveCounterRaid)
        reviveCounterRaid = okReviveRaid and inReviveRaid == true
    end

    if reviveCounterRaid and raidId >= 4 and type(reviveCounter) == "number" and reviveCounter <= 24 then
        return nil
    end

    local kind = "dungeon"
    if reviveCounterRaid and raidId > 0 then
        kind = "trial"
    end

    local key = table.concat({
        kind,
        tostring(parentZoneId),
        tostring(difficulty),
        tostring(raidId),
        tostring(mapId),
    }, ":")

    return {
        key = key,
        kind = kind,
        zoneId = zoneId,
        parentZoneId = parentZoneId,
        mapId = mapId,
        difficulty = difficulty,
        raidId = raidId,
    }
end

function Greed:StartTradeLootRun(activity)
    local session = self:GetTradeLootSession()
    session.state = "active"
    session.generation = (session.generation or 0) + 1
    session.activity = activity
    session.activityKey = activity and activity.key or nil
    session.startedAt = GetGreedTradeNowMs()
    session.itemOrder = 0
    session.itemsByUniqueId = {}
    session.orderedUniqueIds = {}
    session.pendingLoot = {}
    session.recentSlots = {}
    session.validationDirty = true
    session.preparedBatches = nil
    session.preparedBatchIndex = 0
end

function Greed:RefreshTradeLootActivityState()
    local session = self:GetTradeLootSession()
    local checkReason = session.activityCheckReason
    session.activityCheckPending = false
    session.activityCheckReason = nil

    local activity = self:GetCurrentTradeActivityIdentity()
    if activity then
        if session.state == "active" and session.activityKey == activity.key then
            session.activity = activity
            return
        end

        self:StartTradeLootRun(activity)
        return
    end

    if session.state == "active" then
        if checkReason ~= "activated" then return end
        session.state = "retained"
        session.leftAt = GetGreedTradeNowMs()
    end
end

function Greed:ScheduleTradeLootActivityCheck(reason)
    local session = self:GetTradeLootSession()
    session.activityCheckPending = true
    session.activityCheckReason = reason
    self.tradeLootActivityCheckToken = (self.tradeLootActivityCheckToken or 0) + 1
    local token = self.tradeLootActivityCheckToken

    if type(zo_callLater) ~= "function" then
        self:RefreshTradeLootActivityState()
        return
    end

    zo_callLater(function()
        if self.tradeLootActivityCheckToken ~= token then return end
        self:RefreshTradeLootActivityState()
    end, GREED_TRADE_ACTIVITY_RECHECK_DELAY_MS)
end

function Greed:OnTradeLootPlayerDeactivated()
    local session = self:GetTradeLootSession()
    session.activityCheckPending = true
    session.deactivatedAt = GetGreedTradeNowMs()
end

function Greed:IsTradeLootBagSupported(bagId)
    if type(self.IsOwnedInventoryBagSupported) == "function" then
        return self:IsOwnedInventoryBagSupported(bagId)
    end

    return BAG_BACKPACK ~= nil and bagId == BAG_BACKPACK
end

function Greed:GetTradeLootUniqueIdKey(bagId, slotIndex)
    if type(GetItemUniqueId) ~= "function" then return nil end

    local ok, uniqueId = pcall(GetItemUniqueId, bagId, slotIndex)
    if not ok or uniqueId == nil then return nil end

    local key
    if type(zo_getSafeId64Key) == "function" then
        local okKey, safeKey = pcall(zo_getSafeId64Key, uniqueId)
        if okKey and safeKey ~= nil then key = tostring(safeKey) end
    end
    if (not key or key == "") and type(Id64ToString) == "function" then
        local okText, textKey = pcall(Id64ToString, uniqueId)
        if okText and textKey ~= nil then key = tostring(textKey) end
    end
    if not key or key == "" then
        key = tostring(uniqueId)
    end

    if key == "" or key == "0" then return nil end
    return key
end

function Greed:IsTradeLootSlotTradeable(bagId, slotIndex)
    if not self:HasTradeLootValidationApis() then return false end

    local okTradeable, tradeable = pcall(IsItemBoPAndTradeable, bagId, slotIndex)
    if not okTradeable or tradeable ~= true then return false end

    local okTime, secondsRemaining = pcall(GetItemBoPTimeRemainingSeconds, bagId, slotIndex)
    if not okTime or type(secondsRemaining) ~= "number" or secondsRemaining <= 0 then
        return false
    end

    return true
end

function Greed:GetTradeLootSlotSnapshot(bagId, slotIndex)
    if not self:IsTradeLootBagSupported(bagId) then return nil end
    if type(slotIndex) ~= "number" then return nil end

    local itemLink = self:GetSafeBagItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return nil end

    local uniqueId = self:GetTradeLootUniqueIdKey(bagId, slotIndex)
    if not uniqueId then return nil end

    local itemId = self:GetItemIdFromLink(itemLink)
    if not itemId then return nil end

    return {
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = itemLink,
        itemId = itemId,
        uniqueId = uniqueId,
        capturedAt = GetGreedTradeNowMs(),
    }
end

function Greed:PruneTradeLootRuntimeLists(session, now)
    now = now or GetGreedTradeNowMs()

    local function pruneTimedList(list, maxCount)
        local writeIndex = 1
        for index = 1, #list do
            local entry = list[index]
            if entry and (now - (entry.capturedAt or entry.createdAt or 0)) <= GREED_TRADE_LOOT_MATCH_WINDOW_MS then
                list[writeIndex] = entry
                writeIndex = writeIndex + 1
            end
        end
        for index = writeIndex, #list do
            list[index] = nil
        end
        while #list > maxCount do
            table.remove(list, 1)
        end
    end

    pruneTimedList(session.pendingLoot or {}, GREED_TRADE_PENDING_LOOT_MAX)
    pruneTimedList(session.recentSlots or {}, GREED_TRADE_RECENT_SLOT_MAX)
end

function Greed:RememberTradeLootItem(snapshot)
    if not snapshot or not snapshot.uniqueId then return false end
    if not self:IsTradeLootSlotTradeable(snapshot.bagId, snapshot.slotIndex) then return false end

    local session = self:GetTradeLootSession()
    if session.state ~= "active" then return false end

    if session.itemsByUniqueId[snapshot.uniqueId] then
        return true
    end

    session.itemOrder = (session.itemOrder or 0) + 1
    session.itemsByUniqueId[snapshot.uniqueId] = {
        uniqueId = snapshot.uniqueId,
        itemId = snapshot.itemId,
        order = session.itemOrder,
        acquiredAt = snapshot.capturedAt or GetGreedTradeNowMs(),
    }
    table.insert(session.orderedUniqueIds, snapshot.uniqueId)
    self:ClearTradeLootPreparedBatches()
    return true
end

function Greed:FindPendingTradeLootIndexForSnapshot(session, snapshot)
    if not session or not snapshot then return nil end
    local now = GetGreedTradeNowMs()
    self:PruneTradeLootRuntimeLists(session, now)

    for index = #session.pendingLoot, 1, -1 do
        local pending = session.pendingLoot[index]
        if pending and pending.itemId == snapshot.itemId and (now - (pending.createdAt or 0)) <= GREED_TRADE_LOOT_MATCH_WINDOW_MS then
            return index
        end
    end

    return nil
end

function Greed:AddRecentTradeLootSlot(snapshot)
    local session = self:GetTradeLootSession()
    table.insert(session.recentSlots, snapshot)
    self:PruneTradeLootRuntimeLists(session, GetGreedTradeNowMs())
end

function Greed:TryRememberRecentTradeLootSlot(itemId)
    local session = self:GetTradeLootSession()
    local now = GetGreedTradeNowMs()
    self:PruneTradeLootRuntimeLists(session, now)

    for index = #session.recentSlots, 1, -1 do
        local snapshot = session.recentSlots[index]
        if snapshot and snapshot.itemId == itemId and (now - (snapshot.capturedAt or 0)) <= GREED_TRADE_LOOT_MATCH_WINDOW_MS then
            if self:RememberTradeLootItem(snapshot) then
                table.remove(session.recentSlots, index)
                return true
            end
        end
    end

    return false
end

function Greed:RecordTradeLootEvent(itemLink, itemId, quantity)
    if not self:HasTradeLootValidationApis() then return end

    self:RefreshTradeLootActivityState()
    local session = self:GetTradeLootSession()
    if session.state ~= "active" then return end

    itemId = itemId or self:GetItemIdFromLink(itemLink)
    if type(itemId) ~= "number" or itemId <= 0 then return end

    if self:TryRememberRecentTradeLootSlot(itemId) then
        return
    end

    table.insert(session.pendingLoot, {
        itemId = itemId,
        quantity = quantity or 1,
        createdAt = GetGreedTradeNowMs(),
    })
    self:PruneTradeLootRuntimeLists(session)
end

function Greed:OnTradeLootInventorySlotUpdated(bagId, slotIndex)
    if not self:IsTradeLootBagSupported(bagId) then return end

    local session = self:GetTradeLootSession()
    if session.preparedBatches ~= nil then
        session.preparedBatches = nil
        session.preparedBatchIndex = 0
        session.validationDirty = true
    end

    if session.state ~= "active" or not self:HasTradeLootValidationApis() then return end

    local snapshot = self:GetTradeLootSlotSnapshot(bagId, slotIndex)
    if not snapshot then return end

    self:AddRecentTradeLootSlot(snapshot)
    local pendingIndex = self:FindPendingTradeLootIndexForSnapshot(session, snapshot)
    if pendingIndex and self:RememberTradeLootItem(snapshot) then
        table.remove(session.pendingLoot, pendingIndex)
    end
end

function Greed:ValidateTradeLootSessionItems()
    if not self:HasTradeLootValidationApis() then
        return nil, "missing-api"
    end

    local session = self:GetTradeLootSession()
    if session.state ~= "active" and session.state ~= "retained" then
        return {}
    end

    local wanted = session.itemsByUniqueId or {}
    local foundByUniqueId = {}
    for _, bagId in ipairs(self:GetOwnedBagIds()) do
        local bagSize = self:GetSafeBagSize(bagId)
        if bagSize > 0 then
            for slotIndex = 0, bagSize - 1 do
                local uniqueId = self:GetTradeLootUniqueIdKey(bagId, slotIndex)
                if uniqueId and wanted[uniqueId] and self:IsTradeLootSlotTradeable(bagId, slotIndex) then
                    local itemLink = self:GetSafeBagItemLink(bagId, slotIndex)
                    if itemLink and itemLink ~= "" then
                        foundByUniqueId[uniqueId] = {
                            uniqueId = uniqueId,
                            itemId = wanted[uniqueId].itemId,
                            itemLink = itemLink,
                            order = wanted[uniqueId].order or 0,
                        }
                    end
                end
            end
        end
    end

    local validItems = {}
    local compactedMap = {}
    local compactedOrder = {}
    for _, uniqueId in ipairs(session.orderedUniqueIds or {}) do
        local item = foundByUniqueId[uniqueId]
        if item then
            compactedMap[uniqueId] = wanted[uniqueId]
            table.insert(compactedOrder, uniqueId)
            table.insert(validItems, item)
        end
    end

    session.itemsByUniqueId = compactedMap
    session.orderedUniqueIds = compactedOrder
    session.validationDirty = false
    return validItems
end

function Greed:BuildTradeLootBatches(items)
    local batches = {}
    local prefix = T("Tradeable loot:")
    local current = prefix
    local currentCount = 0

    for _, item in ipairs(items or {}) do
        local itemLink = item and item.itemLink or nil
        if type(itemLink) == "string" and itemLink ~= "" then
            local candidate = currentCount == 0 and (prefix .. " " .. itemLink) or (current .. " " .. itemLink)
            if currentCount > 0 and #candidate > GREED_TRADE_CHAT_MAX_CHARS then
                table.insert(batches, current)
                current = prefix .. " " .. itemLink
                currentCount = 1
            else
                current = candidate
                currentCount = currentCount + 1
            end
        end
    end

    if currentCount > 0 then
        table.insert(batches, current)
    end

    return batches
end

function Greed:GetCurrentChatDraftText()
    local editBox = _G and _G.ZO_ChatWindowTextEntryEditBox or nil
    if editBox and type(editBox.GetText) == "function" then
        local ok, text = pcall(function()
            return editBox:GetText()
        end)
        if ok and type(text) == "string" then return text end
    end

    local chatSystem = CHAT_SYSTEM
    if type(ZO_GetChatSystem) == "function" then
        local okChat, resolvedChatSystem = pcall(ZO_GetChatSystem)
        if okChat and resolvedChatSystem then chatSystem = resolvedChatSystem end
    end

    local textEntry = chatSystem and chatSystem.textEntry or nil
    local textEdit = textEntry and textEntry.editControl or nil
    if textEdit and type(textEdit.GetText) == "function" then
        local ok, text = pcall(function()
            return textEdit:GetText()
        end)
        if ok and type(text) == "string" then return text end
    end
    if textEntry and type(textEntry.GetText) == "function" then
        local ok, text = pcall(function()
            return textEntry:GetText()
        end)
        if ok and type(text) == "string" then return text end
    end

    return ""
end

function Greed:PrepareTradeLootBatchInGroupChat(batch, batchIndex, batchCount)
    if not self:IsTradeLootGroupAvailable() then
        SafeAnnounce(T("Greed: You must be in a group to prepare Group chat trade links."))
        return false
    end

    if CHAT_CHANNEL_PARTY == nil then
        SafeAnnounce(T("Greed: Group chat is unavailable."))
        return false
    end

    if TrimText(self:GetCurrentChatDraftText()) ~= "" then
        SafeAnnounce(T("Greed: Chat already contains unsent text. Send or clear it before running /greedtrade."))
        return false
    end

    local chatSystem = CHAT_SYSTEM
    if type(ZO_GetChatSystem) == "function" then
        local okChat, resolvedChatSystem = pcall(ZO_GetChatSystem)
        if okChat and resolvedChatSystem then chatSystem = resolvedChatSystem end
    end

    local okDraft = false
    if chatSystem and type(chatSystem.StartTextEntry) == "function" then
        okDraft = pcall(function()
            chatSystem:StartTextEntry(batch, CHAT_CHANNEL_PARTY, nil, true)
        end)
    end
    if not okDraft and type(StartChatInput) == "function" then
        okDraft = pcall(function()
            StartChatInput(batch, CHAT_CHANNEL_PARTY, nil)
        end)
    end

    if not okDraft then
        SafeAnnounce(T("Greed: Chat input is unavailable."))
        return false
    end

    SafeAnnounce(T("Greed: Prepared trade batch %d/%d in Group chat. Press Enter to send it.", batchIndex, batchCount))
    return true
end

function Greed:PrepareGreedTrade()
    if not self:HasTradeLootValidationApis() then
        SafeAnnounce(T("Greed: Trade item validation APIs are unavailable."))
        return
    end

    self:RefreshTradeLootActivityState()
    local session = self:GetTradeLootSession()
    local items = self:ValidateTradeLootSessionItems()
    if not items or #items == 0 then
        session.preparedBatches = nil
        session.preparedBatchIndex = 0
        SafeAnnounce(T("Greed: No tradeable loot from the most recent run is available."))
        return
    end

    local batches = self:BuildTradeLootBatches(items)
    if #batches == 0 then
        SafeAnnounce(T("Greed: No tradeable loot from the most recent run is available."))
        return
    end

    session.preparedBatches = batches
    session.preparedBatchIndex = 0
    session.validationDirty = false

    if self:PrepareTradeLootBatchInGroupChat(batches[1], 1, #batches) then
        session.preparedBatchIndex = 1
    end
end

function Greed:PrepareNextGreedTrade()
    local session = self:GetTradeLootSession()
    if session.validationDirty == true or type(session.preparedBatches) ~= "table" then
        SafeAnnounce(T("Greed: Run /greedtrade again before using /greedtrade next."))
        return
    end

    local nextIndex = (session.preparedBatchIndex or 0) + 1
    if nextIndex > #session.preparedBatches then
        SafeAnnounce(T("Greed: No additional trade batches remain."))
        return
    end

    if self:PrepareTradeLootBatchInGroupChat(session.preparedBatches[nextIndex], nextIndex, #session.preparedBatches) then
        session.preparedBatchIndex = nextIndex
    end
end

function Greed:HandleGreedTradeCommand(args)
    local command = string.lower(TrimText(args or ""))
    if command == "" then
        self:PrepareGreedTrade()
        return
    end

    if command == "next" then
        self:PrepareNextGreedTrade()
        return
    end

    if command == "clear" then
        self:ResetTradeLootSession()
        SafeAnnounce(T("Greed: Trade loot session cleared."))
        return
    end

    SafeAnnounce(T("Greed: Use /greedtrade, /greedtrade next, or /greedtrade clear."))
end

function Greed:RegisterTradeLootRuntimeEvents()
    if self.tradeLootRuntimeEventsRegistered == true then return end
    if not EVENT_MANAGER then return end

    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "TradeLootPlayerActivated", EVENT_PLAYER_ACTIVATED, function()
            self:ScheduleTradeLootActivityCheck("activated")
        end)
    end

    if EVENT_PLAYER_DEACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "TradeLootPlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function()
            self:OnTradeLootPlayerDeactivated()
        end)
    end

    if EVENT_ZONE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "TradeLootZoneChanged", EVENT_ZONE_CHANGED, function()
            self:ScheduleTradeLootActivityCheck("zone")
        end)
    end

    self.tradeLootRuntimeEventsRegistered = true
end

function Greed:CreateDropLogEntryId()
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self.dropLogEntryIdCounter = (self.dropLogEntryIdCounter or 0) + 1
    return tostring(now) .. ":" .. tostring(self.dropLogEntryIdCounter)
end

function Greed:EnsureDropLogEntryId(entry)
    if type(entry) ~= "table" then return nil end

    if type(entry.id) ~= "string" or entry.id == "" then
        entry.id = self:CreateDropLogEntryId()
    end

    return entry.id
end

function Greed:RemoveDropLogEntryById(entryId)
    if not entryId or entryId == "" then return end
    if not self.savedVars or not self.savedVars.dropLog or type(self.savedVars.dropLog.entries) ~= "table" then return end

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    if self.dropLogDeleteInProgressId == entryId and (now - (self.dropLogDeleteInProgressAt or 0)) < 250 then
        return
    end
    self.dropLogDeleteInProgressId = entryId
    self.dropLogDeleteInProgressAt = now

    for index, entry in ipairs(self.savedVars.dropLog.entries) do
        if self:EnsureDropLogEntryId(entry) == entryId then
            table.remove(self.savedVars.dropLog.entries, index)
            break
        end
    end

    local controls = self.dropListControls
    local visibleRows = controls and controls.visibleRowCount or DROP_LOG_MAX_VISIBLE_ROWS
    local remainingCount = self:GetDropListDisplayEntryCount()
    local maxScrollOffset = math.max(0, remainingCount - visibleRows)
    self.savedVars.dropLog.scrollOffset = math.max(0, math.min(maxScrollOffset, math.floor(self.savedVars.dropLog.scrollOffset or 0)))

    self:RefreshDropListWindow()
end

function Greed:RemoveDropLogEntry(index)
    if not self.savedVars or not self.savedVars.dropLog or type(self.savedVars.dropLog.entries) ~= "table" then return end
    if type(index) ~= "number" or index < 1 or index > #self.savedVars.dropLog.entries then return end

    table.remove(self.savedVars.dropLog.entries, index)

    local controls = self.dropListControls
    local visibleRows = controls and controls.visibleRowCount or DROP_LOG_MAX_VISIBLE_ROWS
    local remainingCount = self:GetDropListDisplayEntryCount()
    local maxScrollOffset = math.max(0, remainingCount - visibleRows)
    self.savedVars.dropLog.scrollOffset = math.max(0, math.min(maxScrollOffset, math.floor(self.savedVars.dropLog.scrollOffset or 0)))

    self:RefreshDropListWindow()
end

function Greed:CopyDropLogItemLink(entry)
    if not entry then return end

    local itemText = entry.itemLink or ""
    if itemText == "" then
        SafeAnnounce(T("Greed: No real item link is available for this Drop List row."))
        return
    end

    if StartChatInput then
        StartChatInput(itemText)
    else
        SafeAnnounce(T("Greed item: %s", itemText))
    end
end

function Greed:GetDropWhisperTarget(entry)
    if not entry then return "" end

    local displayName = self:NormalizeLootDisplayName(entry.looterDisplayName)
    if displayName then return displayName end

    displayName = self:NormalizeLootDisplayName(entry.rawReceivedBy)
    if displayName then return displayName end

    local player = self:CleanEsoDisplayText(entry.receivedBy or "")
    if self:LooksLikeLootChatMessage(player) then
        local parsedPlayer = self:ExtractPlayerFromLootChatMessage(player, entry.rawReceivedBy, nil)
        if parsedPlayer and parsedPlayer ~= "" then
            player = parsedPlayer
        end
    end

    player = player:gsub("^%s+", ""):gsub("%s+$", "")
    player = player:gsub("^Tell%s+to%s+", "")
    player = player:gsub("^To%s+", "")
    player = player:gsub("^/w%s+", "")
    player = player:gsub("^/whisper%s+", "")
    player = player:gsub("^/tell%s+", "")
    player = player:gsub('^"(.-)"$', "%1")
    player = player:gsub("^'(.-)'$", "%1")
    player = player:gsub("%s+[Hh]as$", ""):gsub("%s+[Hh]ave$", "")
    player = self:CleanEsoDisplayText(player)
    player = player:gsub("^%s+", ""):gsub("%s+$", "")

    if player == "Unknown" then return "" end
    return player
end

function Greed:StartDropWhisper(entry)
    if not entry then return end

    local message = self:BuildDropAskMessage(entry)
    local player = self:GetDropWhisperTarget(entry)

    if entry.source == "test" or entry.testRow == true then
        local testDraft = "/say " .. (player ~= "" and (player .. ": ") or "") .. message
        if StartChatInput then
            StartChatInput(testDraft)
        else
            SafeAnnounce(testDraft)
        end
        return
    end

    if player == "" then
        if StartChatInput then
            StartChatInput(message)
        else
            SafeAnnounce(message)
        end
        return
    end

    -- Do not build a `/w Player Message` command here. Character names with spaces
    -- can make ESO treat the message as part of the recipient. Passing the channel
    -- and target separately opens a real whisper draft to exactly this player.
    if StartChatInput and CHAT_CHANNEL_WHISPER then
        local ok = pcall(function()
            StartChatInput(message, CHAT_CHANNEL_WHISPER, player)
        end)
        if ok then return end
    end

    if StartChatInput then
        StartChatInput(message)
    else
        SafeAnnounce(T("Greed whisper to %s: %s", player, message))
    end
end

function Greed:GetDropWhisperCommand(entry)
    if not entry then return nil end

    local message = self:BuildDropAskMessage(entry)
    local player = self:GetDropWhisperTarget(entry)

    if player == "" then
        return message
    end

    return "/w " .. player .. " " .. message
end

function Greed:CopyDropAskMessage(entry)
    if not entry then return end

    if entry.selfLoot == true then
        SafeAnnounce(T("Greed: You looted this item."))
        return
    end

    self:StartDropWhisper(entry)
end

function Greed:GetTestDropItemLink(setName, setId, slotKind, slotKey)
    local setData = {
        name = setName,
        baseName = setName,
        lookupName = setName,
        setId = setId,
        pieces = {},
        weapons = {},
        isPerfectedRow = false,
    }

    local column
    local piece
    if slotKind == "weapon" then
        local weapon = WEAPON_ITEM_BY_KEY[slotKey]
        if not weapon then return nil, nil end
        column = {
            kind = "weapon",
            key = weapon.key,
            label = weapon.label,
            shortLabel = weapon.shortLabel,
            weaponType = weapon.weaponType,
            fallbackIcon = weapon.fallbackIcon,
        }
        piece = { type = weapon.key }
    else
        column = self:GetColumnForDropSlot(slotKind, slotKey)
        if not column then return nil, nil end
        piece = {}
    end

    local itemLink, itemId = self:ResolveItemLink(setData, column, piece)
    return itemLink, itemId
end

function Greed:ResolveDropLogTestItemLink(testData)
    if not testData then return nil, nil end
    if type(testData.itemLink) == "string" and testData.itemLink ~= "" then
        return testData.itemLink, testData.itemId
    end

    return self:GetTestDropItemLink(testData.setName, testData.setId, testData.slotKind, testData.slotKey)
end

function Greed:AddResolvedDropLogTestEntry(testData, timestamp, timestampText, logToDropList)
    local itemLink, itemId = self:ResolveDropLogTestItemLink(testData)
    if not itemLink or itemLink == "" then
        SafeAnnounce(T("Greed: Could not resolve real test item link for %s %s.", tostring(testData.setName), tostring(testData.slotKey)))
        return false
    end

    local match = self:FindDropLogWishlistMatch(itemLink)
    local itemName = self:GetDropLogItemDisplayText(itemLink, itemLink, match)
    local slotLabel = self:GetDropSlotLabel(testData.slotKind, testData.slotKey)
    local looterDisplayName = self:NormalizeLootDisplayName(testData.looterDisplayName)
    if not looterDisplayName and type(GetDisplayName) == "function" then
        local okDisplayName, displayName = pcall(GetDisplayName)
        if okDisplayName then
            looterDisplayName = self:NormalizeLootDisplayName(displayName)
        end
    end

    local entry = {
        receivedBy = testData.receivedBy,
        rawReceivedBy = testData.receivedBy,
        looterCharacterName = testData.receivedBy,
        looterDisplayName = looterDisplayName,
        itemLink = itemLink,
        itemId = itemId,
        itemName = itemName,
        traitName = testData.traitName,
        quantity = 1,
        selfLoot = false,
        wishlistMatched = match ~= nil,
        collected = false,
        collectionKnown = false,
        pageName = match and match.pageName or nil,
        matchedPages = match and match.matchedPages or nil,
        matchedPageList = match and match.matchedPageList or nil,
        setName = match and match.setName or testData.setName,
        slotLabel = slotLabel,
        source = "test",
        testRow = true,
        timestamp = timestamp,
        timestampText = timestampText,
    }

    if logToDropList == true then
        self:EnsureDropLogEntryId(entry)
        table.insert(self.savedVars.dropLog.entries, 1, entry)
    end

    -- Test Drop Row should also preview the floating Greed Drop Text, even when the
    -- test item is not on the user's wishlist.  This force flag is only passed here.
    self:AddDropTextAlert(entry, true)

    return true
end

function Greed:GetFirstActiveWantedDropLogTestData()
    local pageName = self:GetCurrentPageName()
    local rows = self:BuildDisplayFavorites()
    local context = {
        pageName = pageName,
        rows = rows,
    }

    if not rows or #rows == 0 then
        return nil, "empty"
    end

    for _, row in ipairs(rows) do
        for _, column in ipairs(GreedData.armorSlots or {}) do
            local piece = row.pieces and row.pieces[column.key] or nil
            if piece then
                local itemLink, itemId = self:ResolveItemLink(row, column, piece)
                if itemLink and itemLink ~= "" then
                    local slotKind, slotKey = self:GetLootSlotKeyFromItemLink(itemLink)
                    if slotKind and slotKey and self:GetActiveDropLogWishlistMatch({ itemLink = itemLink }, context) then
                        return {
                            receivedBy = "Wanted Test Drop",
                            setName = row.name or row.baseName,
                            setId = row.setId,
                            slotKind = slotKind,
                            slotKey = slotKey,
                            traitName = self:GetTraitNameFromItemLink(itemLink),
                            itemLink = itemLink,
                            itemId = itemId,
                        }
                    end
                end
            end
        end

        for _, weapon in ipairs(WEAPON_ITEMS) do
            local piece = row.weapons and row.weapons[weapon.key] or nil
            if piece then
                local column = self:GetColumnForDropSlot("weapon", weapon.key)
                local itemLink, itemId
                if column then
                    itemLink, itemId = self:ResolveItemLink(row, column, piece)
                end
                if itemLink and itemLink ~= "" and self:GetActiveDropLogWishlistMatch({ itemLink = itemLink }, context) then
                    return {
                        receivedBy = "Wanted Test Drop",
                        setName = row.name or row.baseName,
                        setId = row.setId,
                        slotKind = "weapon",
                        slotKey = weapon.key,
                        traitName = self:GetTraitNameFromItemLink(itemLink),
                        itemLink = itemLink,
                        itemId = itemId,
                    }
                end
            end
        end
    end

    return nil, "unresolved"
end

function Greed:AddDropLogTestEntry()
    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()

    local dropListEnabled = self.savedVars.dropLog.enabled == true
    self.savedVars.dropLog.entries = self.savedVars.dropLog.entries or {}

    local timestamp = GetTimeStamp and GetTimeStamp() or 0
    local timestampText = GetTimeString and GetTimeString() or "test"
    local added = 0

    local normalTests = {
        {
            receivedBy = "Test Loot Gremlin",
            setName = "Pillager's Profit",
            setId = 649,
            slotKind = "weapon",
            slotKey = "restorationStaff",
            traitName = "Infused",
        },
        {
            receivedBy = "Sir Hoards-a-Lot",
            setName = "Powerful Assault",
            setId = 180,
            slotKind = "weapon",
            slotKey = "frostStaff",
            traitName = "Powered",
        },
        {
            receivedBy = "Loot Goblin",
            setName = "Spell Power Cure",
            setId = 185,
            slotKind = "armor",
            slotKey = "legs",
            traitName = "Divines",
        },
    }

    local tests = {}
    local wantedTest, wantedReason = self:GetFirstActiveWantedDropLogTestData()
    if wantedTest then
        table.insert(tests, wantedTest)
        local activeMatchContext = self:BuildDropLogActiveWishlistMatchContext()
        local normalAdded = 0
        for _, testData in ipairs(normalTests) do
            local itemLink = self:ResolveDropLogTestItemLink(testData)
            local activeMatch = itemLink and self:GetActiveDropLogWishlistMatch({ itemLink = itemLink }, activeMatchContext) or nil
            if not activeMatch then
                table.insert(tests, testData)
                normalAdded = normalAdded + 1
            end
            if normalAdded >= 2 then break end
        end
    else
        tests = normalTests
        if wantedReason == "empty" then
            SafeAnnounce(T("Greed: No wanted test row could be generated because the active page is empty."))
        end
    end

    for _, testData in ipairs(tests) do
        if self:AddResolvedDropLogTestEntry(testData, timestamp, timestampText, dropListEnabled) then
            added = added + 1
        end
    end

    if dropListEnabled then
        self.savedVars.dropLog.scrollOffset = 0
        while #self.savedVars.dropLog.entries > DROP_LOG_MAX_ENTRIES do
            table.remove(self.savedVars.dropLog.entries)
        end
        self:ShowDropListWindow(false)
    end

    self:RefreshDropOptionsState()
    if dropListEnabled then
        SafeAnnounce(T("Greed: %d test Drop List rows added.", added))
    else
        SafeAnnounce(T("Greed: %d test Drop Text alerts previewed. Drop List window remains disabled.", added))
    end
end

function Greed:GetDropLogTextSizeLabel()
    local textSize = self:GetDropLogTextSizeData()
    return textSize.label or T("Normal")
end

function Greed:SetDropLogTextSizeByLabel(label)
    self:InitializeDropLogSettings()

    for index, sizeData in ipairs(DROP_LOG_TEXT_SIZES) do
        if sizeData.label == label then
            self.savedVars.dropLog.textSize = index
            self:LayoutDropListWindow()
            self:ApplyDropListFont()
            self:RefreshDropListWindow()
            self:RefreshDropOptionsState()
            return
        end
    end
end

function Greed:SetDropLogFontByLabel(label)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.fontName = FONT_OPTION_BY_LABEL[label] and label or DEFAULT_FONT_NAME
    self:LayoutDropListWindow()
    self:ApplyDropListFont()
    self:RefreshDropListWindow()
    self:RefreshDropOptionsState()
end

function Greed:SetTextPromptFontByLabel(label)
    self:InitializeTextPromptSettings()
    local safeLabel = FONT_OPTION_BY_LABEL[label] and label or DEFAULT_FONT_NAME
    self.savedVars.textPrompts.fontName = safeLabel
    self.savedVars.textPrompts.drop.fontName = safeLabel
    self.savedVars.textPrompts.spaulder.fontName = safeLabel
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshDropOptionsState()
end

function Greed:ConfigureChoiceDropdown(dropdown, choices, selectedLabel, setter)
    if not dropdown or not ZO_ComboBox_ObjectFromContainer then return end

    local comboBox = ZO_ComboBox_ObjectFromContainer(dropdown)
    if not comboBox then return end

    comboBox:SetSortsItems(false)
    if type(comboBox.ClearItems) == "function" then
        comboBox:ClearItems()
    end

    for _, label in ipairs(choices or {}) do
        local choice = label
        comboBox:AddItem(comboBox:CreateItemEntry(choice, function()
            setter(choice)
        end))
    end

    comboBox:SetSelectedItem(selectedLabel or (choices and choices[1]) or "")
end

function Greed:ConfigureFontDropdown(dropdown, selectedLabel, setter)
    if not dropdown or not ZO_ComboBox_ObjectFromContainer then return end

    local comboBox = ZO_ComboBox_ObjectFromContainer(dropdown)
    if not comboBox then return end

    comboBox:SetSortsItems(false)
    if type(comboBox.ClearItems) == "function" then
        comboBox:ClearItems()
    end

    for _, fontLabel in ipairs(FONT_CHOICE_LABELS) do
        local choice = fontLabel
        comboBox:AddItem(comboBox:CreateItemEntry(choice, function()
            setter(choice)
        end))
    end

    comboBox:SetSelectedItem(FONT_OPTION_BY_LABEL[selectedLabel] and selectedLabel or DEFAULT_FONT_NAME)
end

function Greed:IsLootItemCollectedInStickerbook(itemLink)
    if not itemLink or itemLink == "" then return nil, false end

    local setId = self:GetCollectionSetId(nil, itemLink)
    if not setId then
        return nil, false
    end

    local collectionSlot = self:GetCollectionSlotFromItemLink(itemLink)
    if collectionSlot and type(IsItemSetCollectionSlotUnlocked) == "function" then
        local ok, isUnlocked = pcall(function()
            return IsItemSetCollectionSlotUnlocked(setId, collectionSlot)
        end)

        if ok and type(isUnlocked) == "boolean" then
            return isUnlocked, true
        end
    end

    local pieceId = self:GetCollectionPieceIdForItem(setId, itemLink, collectionSlot)
    if pieceId and type(IsItemSetCollectionPieceUnlocked) == "function" then
        local ok, isUnlocked = pcall(function()
            return IsItemSetCollectionPieceUnlocked(pieceId)
        end)

        if ok and type(isUnlocked) == "boolean" then
            return isUnlocked, true
        end
    end

    return nil, false
end

function Greed:DropLogDebug(message)
    if self.savedVars and self.savedVars.dropLog and self.savedVars.dropLog.debugLoot == true then
        SafeAnnounce("Greed loot debug: " .. tostring(message or ""))
    end
end

function Greed:BuildItemLinkFromItemId(itemId)
    if not itemId or tonumber(itemId) == nil or tonumber(itemId) <= 0 then return nil end
    itemId = tonumber(itemId)

    local link = libSets.buildItemLink(itemId)
    if type(link) == "string" and link ~= "" and link:find("|H", 1, true) then
        return link
    end

    -- Last-resort generic CP160 purple item link. This is mainly for group loot events
    -- where ESO provides an itemId but the localized item name is not a clickable link.
    local candidate = string.format("|H1:item:%d:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemId)
    if type(GetItemLinkName) == "function" then
        local ok, name = pcall(function() return GetItemLinkName(candidate) end)
        if ok and type(name) == "string" and name ~= "" then
            return candidate
        end
    end

    return candidate
end

function Greed:ExtractLootItemLink(itemText, itemId)
    if type(itemText) == "string" and itemText ~= "" then
        local link = itemText:match("(|H.-|h.-|h)")
        if link then return link end

        if itemText:find("|H", 1, true) then
            return itemText
        end
    end

    return self:BuildItemLinkFromItemId(itemId)
end

function Greed:GetTraitNameFromItemLink(itemLink)
    if not itemLink or type(GetItemLinkTraitInfo) ~= "function" then return "" end

    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE and GetString then
        local ok, traitName = pcall(function()
            return GetString("SI_ITEMTRAITTYPE", traitType)
        end)
        if ok and type(traitName) == "string" and traitName ~= "" then
            return traitName
        end
    end

    return traitDescription or ""
end

function Greed:GetLootSlotKeyFromItemLink(itemLink)
    if not itemLink then return nil, nil end

    if type(GetItemLinkEquipType) == "function" then
        local equipType = GetItemLinkEquipType(itemLink)
        local equipMap = {
            [EQUIP_TYPE_HEAD] = "head",
            [EQUIP_TYPE_SHOULDERS] = "shoulders",
            [EQUIP_TYPE_CHEST] = "chest",
            [EQUIP_TYPE_HAND] = "hands",
            [EQUIP_TYPE_WAIST] = "waist",
            [EQUIP_TYPE_LEGS] = "legs",
            [EQUIP_TYPE_FEET] = "feet",
            [EQUIP_TYPE_NECK] = "neck",
            [EQUIP_TYPE_RING] = "ring",
        }

        if equipMap[equipType] then
            return "armor", equipMap[equipType]
        end
    end

    if type(GetItemLinkWeaponType) == "function" then
        local weaponType = GetItemLinkWeaponType(itemLink)
        for _, weapon in ipairs(WEAPON_ITEMS) do
            if weapon.weaponType == weaponType then
                return "weapon", weapon.key
            end
        end
    end

    return nil, nil
end

function Greed:GetLootSetInfo(itemLink)
    if not itemLink or type(GetItemLinkSetInfo) ~= "function" then return nil end

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if not hasSet then return nil end

    local itemName = type(GetItemLinkName) == "function" and GetItemLinkName(itemLink) or itemLink
    local numericSetId = tonumber(setId) or setId
    local isPerfected = numericSetId and libSets.IsPerfectedSet(numericSetId) == true
    local perfectedInfo = numericSetId and libSets.GetPerfectedSetInfo(numericSetId) or nil
    local normalSetId = numericSetId

    if perfectedInfo then
        if isPerfected then
            normalSetId = perfectedInfo.nonPerfectedSetId or numericSetId
        else
            normalSetId = numericSetId
        end
    end

    local baseName = self:GetLibSetsSetName(normalSetId) or setName

    return {
        itemLink = itemLink,
        setName = setName,
        baseName = baseName,
        setId = numericSetId,
        itemName = itemName,
        isPerfected = isPerfected == true,
    }
end

function Greed:GetDisplayFavoritesForPage(pageName)
    local profile = self:GetCurrentTrackingProfile()
    local originalPage = profile.currentPage
    profile.currentPage = pageName
    local rows = self:BuildDisplayFavorites()
    profile.currentPage = originalPage
    return rows
end

function Greed:DoesLootMatchRow(row, lootInfo, slotKind, slotKey)
    if not row or not lootInfo or not slotKind or not slotKey then return false end

    local rowSetId = row.setId or self:GetLibSetsSetId(row)
    local idMatches = rowSetId and lootInfo.setId and rowSetId == lootInfo.setId
    local nameMatches = string.lower(row.baseName or row.lookupName or row.name or "") == string.lower(lootInfo.baseName or "")

    if not idMatches then
        if not nameMatches then return false end
        if lootInfo.isPerfected ~= row.isPerfectedRow then return false end
    end

    if slotKind == "armor" then
        if not row.pieces or row.pieces[slotKey] == nil then return false end
        if self:IsMonsterSetData(row) then
            if not MONSTER_ARMOR_SLOT_KEYS[slotKey] then return false end
            local armorType = self:GetArmorTypeFromItemLink(lootInfo.itemLink)
            if not self:MonsterWeightAllowsArmorType(row.armorWeights or row.armorWeight or row.weightPreference, armorType) then
                return false
            end
        end
        return true
    end

    if slotKind == "weapon" then
        return row.weapons and row.weapons[slotKey] ~= nil
    end

    return false
end

function Greed:FindDropLogWishlistMatchInRows(rows, pageName, lootInfo, slotKind, slotKey)
    if not rows or type(pageName) ~= "string" or pageName == "" then return nil end

    for _, row in ipairs(rows or {}) do
        if self:DoesLootMatchRow(row, lootInfo, slotKind, slotKey) then
            return {
                pageName = pageName,
                setName = row.name,
                baseName = row.baseName,
                source = row.source,
                slotKind = slotKind,
                slotKey = slotKey,
                slotLabel = self:GetDropSlotLabel(slotKind, slotKey),
                isPerfected = row.isPerfectedRow == true,
                row = row,
            }
        end
    end

    return nil
end

function Greed:FindDropLogWishlistMatch(itemLink)
    local lootInfo = self:GetLootSetInfo(itemLink)
    if not lootInfo then return nil end

    local slotKind, slotKey = self:GetLootSlotKeyFromItemLink(itemLink)
    if not slotKind or not slotKey then return nil end

    local result
    local matchedPages = {}
    local matchedPageList = {}

    for _, pageName in ipairs(self:GetPageNames()) do
        local rows = self:GetDisplayFavoritesForPage(pageName)
        local match = self:FindDropLogWishlistMatchInRows(rows, pageName, lootInfo, slotKind, slotKey)
        if match then
            if matchedPages[pageName] ~= true then
                matchedPages[pageName] = true
                table.insert(matchedPageList, pageName)
            end

            result = result or match
        end
    end

    if result then
        result.matchedPages = matchedPages
        result.matchedPageList = matchedPageList
    end

    return result
end

function Greed:BuildDropLogActiveWishlistMatchContext()
    return {
        pageName = self:GetCurrentPageName(),
        rows = self:BuildDisplayFavorites(),
    }
end

function Greed:GetActiveDropLogWishlistMatch(entry, context)
    if not entry or type(entry.itemLink) ~= "string" or entry.itemLink == "" then return nil end

    local lootInfo = self:GetLootSetInfo(entry.itemLink)
    if not lootInfo then return nil end

    local slotKind, slotKey = self:GetLootSlotKeyFromItemLink(entry.itemLink)
    if not slotKind or not slotKey then return nil end

    context = context or self:BuildDropLogActiveWishlistMatchContext()
    return self:FindDropLogWishlistMatchInRows(context.rows, context.pageName, lootInfo, slotKind, slotKey)
end

function Greed:GetColumnForDropSlot(slotKind, slotKey)
    if slotKind == "weapon" and WEAPON_ITEM_BY_KEY[slotKey] then
        local weapon = WEAPON_ITEM_BY_KEY[slotKey]
        return {
            kind = "weapon",
            key = weapon.key,
            label = weapon.label,
            shortLabel = weapon.shortLabel,
            weaponType = weapon.weaponType,
            fallbackIcon = weapon.fallbackIcon,
        }
    end

    for _, slot in ipairs(GreedData.armorSlots or {}) do
        if slot.key == slotKey then
            return {
                kind = "armor",
                key = slot.key,
                label = slot.label,
                shortLabel = slot.shortLabel,
                equipType = slot.equipType,
                fallbackIcon = slot.fallbackIcon,
                total = slot.total,
            }
        end
    end

    return nil
end

function Greed:GetActualOwnedStateForDropMatch(match, ownedItemIndex)
    if not match or not match.row or not match.slotKind or not match.slotKey then
        return nil, false
    end

    local column = self:GetColumnForDropSlot(match.slotKind, match.slotKey)
    if not column then return nil, false end

    local piece
    if match.slotKind == "weapon" then
        piece = match.row.weapons and match.row.weapons[match.slotKey]
    else
        piece = match.row.pieces and match.row.pieces[match.slotKey]
    end
    if not piece then return nil, false end

    local ownedCount, neededCount = self:GetPieceCounts(column, piece, match.row, ownedItemIndex)
    return ownedCount >= neededCount, true, ownedCount, neededCount
end

function Greed:GetDropSlotLabel(slotKind, slotKey)
    if slotKind == "weapon" and WEAPON_ITEM_BY_KEY[slotKey] then
        return WEAPON_ITEM_BY_KEY[slotKey].label
    end

    for _, slot in ipairs(GreedData.armorSlots or {}) do
        if slot.key == slotKey then
            return slot.label
        end
    end

    return slotKey or "Unknown"
end

function Greed:CleanEsoDisplayText(value)
    local text = tostring(value or "")
    if text == "" then return "" end
    if text:find("|H", 1, true) then return text end

    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(function()
            return zo_strformat("<<1>>", text)
        end)
        if ok and type(formatted) == "string" and formatted ~= "" then
            text = formatted
        end
    end

    -- ESO display strings can include grammar/gender suffixes like ^Fx.
    -- They are useful internally, but ugly in Greed's visible Drop List.
    text = text:gsub("%^%a+", "")
    return text
end

function Greed:NormalizeLootRecipient(receivedBy, lootedBySelf)
    if lootedBySelf == true then
        if type(GetRawUnitName) == "function" then
            local rawName = GetRawUnitName("player")
            rawName = self:CleanEsoDisplayText(rawName)
            if rawName and rawName ~= "" then return rawName end
        end
        if type(GetUnitName) == "function" then
            local name = self:CleanEsoDisplayText(GetUnitName("player"))
            if name and name ~= "" then return name end
        end
    end

    local player = self:CleanEsoDisplayText(receivedBy)
    if player == "" then return "Unknown" end

    if type(zo_strformat) == "function" and SI_PLAYER_NAME then
        local ok, formatted = pcall(function() return zo_strformat(SI_PLAYER_NAME, player) end)
        if ok and type(formatted) == "string" and formatted ~= "" then
            formatted = self:CleanEsoDisplayText(formatted)
            if formatted ~= "" then return formatted end
        end
    end

    return player
end

function Greed:NormalizeLootDisplayName(displayName)
    displayName = self:CleanEsoDisplayText(displayName)
    if displayName ~= "" and displayName:sub(1, 1) == "@" then
        return displayName
    end
    return nil
end

function Greed:GetOwnLootDisplayName()
    if type(GetUnitDisplayName) == "function" then
        local displayName = self:NormalizeLootDisplayName(GetUnitDisplayName("player"))
        if displayName then return displayName end
    end

    if type(GetDisplayName) == "function" then
        local displayName = self:NormalizeLootDisplayName(GetDisplayName())
        if displayName then return displayName end
    end

    return nil
end

function Greed:LootRecipientNameMatches(candidate, targets)
    candidate = self:CleanEsoDisplayText(candidate)
    if candidate == "" then return false end

    local lowerCandidate = string.lower(candidate)
    if targets[lowerCandidate] then return true end

    if type(zo_strformat) == "function" and SI_PLAYER_NAME then
        local ok, formatted = pcall(function()
            return zo_strformat(SI_PLAYER_NAME, candidate)
        end)
        if ok then
            formatted = self:CleanEsoDisplayText(formatted)
            if formatted ~= "" and targets[string.lower(formatted)] then
                return true
            end
        end
    end

    return false
end

function Greed:GetGroupLootDisplayNameForCharacter(characterName, rawReceivedBy)
    if type(GetGroupSize) ~= "function" or type(GetGroupUnitTagByIndex) ~= "function" or type(GetUnitDisplayName) ~= "function" then
        return nil
    end

    local targets = {}
    local function addTarget(value)
        value = self:CleanEsoDisplayText(value)
        if value ~= "" then
            targets[string.lower(value)] = true
        end
    end

    addTarget(characterName)
    addTarget(rawReceivedBy)
    if next(targets) == nil then return nil end

    local groupSize = GetGroupSize()
    if type(groupSize) ~= "number" or groupSize <= 0 then return nil end

    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag then
            local rawName = type(GetRawUnitName) == "function" and GetRawUnitName(unitTag) or nil
            local unitName = type(GetUnitName) == "function" and GetUnitName(unitTag) or nil
            if self:LootRecipientNameMatches(rawName, targets) or self:LootRecipientNameMatches(unitName, targets) then
                local displayName = self:NormalizeLootDisplayName(GetUnitDisplayName(unitTag))
                if displayName then return displayName end
            end
        end
    end

    return nil
end

function Greed:GetLootRecipientDisplayName(receivedBy, characterName, lootedBySelf)
    local receivedDisplayName = self:NormalizeLootDisplayName(receivedBy)
    if receivedDisplayName then return receivedDisplayName end

    if lootedBySelf == true then
        return self:GetOwnLootDisplayName()
    end

    return self:GetGroupLootDisplayNameForCharacter(characterName, receivedBy)
end

function Greed:GetCleanChatTextForDropLog(text)
    local clean = tostring(text or "")
    if clean == "" then return "" end

    -- Keep this separate from item-link extraction. This is only for readable text and player parsing.
    clean = clean:gsub("|c%x%x%x%x%x%x%x%x", "")
    clean = clean:gsub("|c%x%x%x%x%x%x", "")
    clean = clean:gsub("|r", "")
    clean = clean:gsub("|H.-|h(.-)|h", "%1")
    clean = self:CleanEsoDisplayText(clean)
    clean = clean:gsub("%s+", " ")
    clean = clean:match("^%s*(.-)%s*$") or clean
    return clean
end

function Greed:LooksLikeLootChatMessage(text)
    local clean = string.lower(self:GetCleanChatTextForDropLog(text))
    if clean == "" then return false end

    local lootWords = {
        " looted ",
        " loot ",
        " received ",
        " receives ",
        " acquired ",
        " acquires ",
        " obtained ",
        " obtains ",
        " picked up ",
        " picks up ",
    }

    for _, word in ipairs(lootWords) do
        if string.find(clean, word, 1, true) then
            return true
        end
    end

    return false
end

function Greed:ExtractPlayerFromLootChatMessage(text, fromName, fromDisplayName)
    local clean = self:GetCleanChatTextForDropLog(text)
    local player = nil

    local patterns = {
        "^(.-)%s+[Ll]ooted%s+",
        "^(.-)%s+[Ll]oot%s+",
        "^(.-)%s+[Rr]eceived%s+",
        "^(.-)%s+[Rr]eceives%s+",
        "^(.-)%s+[Aa]cquired%s+",
        "^(.-)%s+[Aa]cquires%s+",
        "^(.-)%s+[Oo]btained%s+",
        "^(.-)%s+[Oo]btains%s+",
        "^(.-)%s+[Pp]icked%s+up%s+",
        "^(.-)%s+[Pp]icks%s+up%s+",
    }

    for _, pattern in ipairs(patterns) do
        local match = clean:match(pattern)
        if match and match ~= "" then
            player = match
            break
        end
    end

    if not player or player == "" then
        player = fromDisplayName or fromName or ""
    end

    player = self:CleanEsoDisplayText(player)
    player = player:gsub("^%s+", ""):gsub("%s+$", "")
    player = player:gsub("%s+[Hh]as$", ""):gsub("%s+[Hh]ave$", "")

    local lowerPlayer = string.lower(player or "")
    local selfLoot = false
    if lowerPlayer == "you" or lowerPlayer == "you have" or lowerPlayer == "your group" then
        selfLoot = true
        player = self:NormalizeLootRecipient(player, true)
    elseif type(GetRawUnitName) == "function" then
        local rawName = self:CleanEsoDisplayText(GetRawUnitName("player"))
        if rawName ~= "" and string.lower(player) == string.lower(rawName) then
            selfLoot = true
        end
    end

    if player == "" then
        player = "Unknown"
    end

    return player, selfLoot
end

function Greed:GetDropLogItemDisplayText(itemLink, rawItemText, match)
    local itemName = ""
    if itemLink and type(GetItemLinkName) == "function" then
        local ok, name = pcall(function() return GetItemLinkName(itemLink) end)
        if ok and type(name) == "string" then
            itemName = self:CleanEsoDisplayText(name)
        end
    end

    if itemName == "" and type(rawItemText) == "string" then
        itemName = self:GetCleanChatTextForDropLog(rawItemText)
    end

    if itemName == "" and match then
        itemName = tostring(match.setName or match.baseName or T("Wishlist item"))
    end

    return itemName
end

function Greed:GetDropLogDuplicateText(value)
    local text = self:CleanEsoDisplayText(value or "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return string.lower(text)
end

function Greed:GetDropLogItemIdForDuplicate(entry)
    if not entry then return nil end

    local itemId = tonumber(entry.itemId)
    if itemId and itemId > 0 then
        return itemId
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        itemId = tonumber(entry.itemLink:match(":item:(%d+)"))
        if itemId and itemId > 0 then
            return itemId
        end
    end

    return nil
end

function Greed:GetDropLogDuplicateParts(entry)
    local itemId = self:GetDropLogItemIdForDuplicate(entry)
    local itemKey
    if itemId then
        itemKey = "id:" .. tostring(itemId)
    else
        itemKey = "text:" .. self:GetDropLogDuplicateText(entry and (entry.itemName or entry.itemLink) or "")
    end

    local traitKey = self:GetDropLogDuplicateText(entry and entry.traitName or "")
    local slotKey = self:GetDropLogDuplicateText(entry and entry.slotLabel or "")
    local playerKey = self:GetDropLogDuplicateText(entry and entry.receivedBy or "")

    return playerKey, itemKey, traitKey, slotKey
end

function Greed:MergeDropLogDuplicateEntry(existing, incoming)
    local merged = {}
    for key, value in pairs(existing or {}) do
        merged[key] = value
    end

    for key, value in pairs(incoming or {}) do
        if value ~= nil and value ~= "" then
            merged[key] = value
        end
    end

    if type(existing and existing.matchedPages) == "table" or type(incoming and incoming.matchedPages) == "table" then
        local pages = {}
        local pageList = {}
        local function addPages(sourcePages)
            if type(sourcePages) ~= "table" then return end
            for pageName, matched in pairs(sourcePages) do
                if type(pageName) == "string" and matched == true and pages[pageName] ~= true then
                    pages[pageName] = true
                    table.insert(pageList, pageName)
                end
            end
        end

        addPages(existing and existing.matchedPages)
        addPages(incoming and incoming.matchedPages)
        if pageList[1] then
            merged.matchedPages = pages
            merged.matchedPageList = pageList
        end
    end

    if type(existing) == "table" and existing.id then
        merged.id = existing.id
    elseif type(incoming) == "table" and incoming.id then
        merged.id = incoming.id
    end

    return merged
end

function Greed:AddOrUpdateDropLogEntry(entry)
    self.savedVars.dropLog.entries = self.savedVars.dropLog.entries or {}
    self:EnsureDropLogEntryId(entry)

    local entries = self.savedVars.dropLog.entries
    local entryTime = tonumber(entry.timestamp or 0) or 0
    local entryPlayer, entryItem, entryTrait, entrySlot = self:GetDropLogDuplicateParts(entry)

    for index, existing in ipairs(entries) do
        local existingTime = tonumber(existing.timestamp or 0) or 0
        local existingPlayer, existingItem, existingTrait, existingSlot = self:GetDropLogDuplicateParts(existing)
        local samePlayer = existingPlayer == entryPlayer
        local sameItem = existingItem == entryItem
        local sameTrait = existingTrait == entryTrait
        local sameSlot = existingSlot == entrySlot
        local closeTime = entryTime == 0 or existingTime == 0 or math.abs(entryTime - existingTime) <= 6

        if samePlayer and sameItem and sameTrait and sameSlot and closeTime then
            entries[index] = self:MergeDropLogDuplicateEntry(existing, entry)
            self.savedVars.dropLog.scrollOffset = 0
            while #entries > DROP_LOG_MAX_ENTRIES do
                table.remove(entries)
            end
            return
        end
    end

    table.insert(entries, 1, entry)
    self.savedVars.dropLog.scrollOffset = 0
    while #entries > DROP_LOG_MAX_ENTRIES do
        table.remove(entries)
    end
end

function Greed:GetDropLogItemQuality(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then return nil end

    if type(GetItemLinkQuality) == "function" then
        local ok, quality = pcall(function()
            return GetItemLinkQuality(itemLink)
        end)
        if ok and type(quality) == "number" then
            return quality
        end
    end

    if type(GetItemLinkDisplayQuality) == "function" then
        local ok, quality = pcall(function()
            return GetItemLinkDisplayQuality(itemLink)
        end)
        if ok and type(quality) == "number" then
            return quality
        end
    end

    return nil
end

function Greed:IsDropLogNormalQualityItem(itemLink)
    local quality = self:GetDropLogItemQuality(itemLink)
    if type(quality) ~= "number" then return false end

    local normalQuality = type(ITEM_DISPLAY_QUALITY_NORMAL) == "number" and ITEM_DISPLAY_QUALITY_NORMAL or 1
    return quality <= normalQuality
end

function Greed:GetDropLogItemTypes(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" or type(GetItemLinkItemType) ~= "function" then
        return nil, nil
    end

    local ok, itemType, specializedItemType = pcall(function()
        return GetItemLinkItemType(itemLink)
    end)
    if ok then
        return itemType, specializedItemType
    end

    return nil, nil
end

function Greed:IsDropLogExcludedCraftingOrGlyphItem(itemLink)
    local itemType, specializedItemType = self:GetDropLogItemTypes(itemLink)

    local function typeMatches(value)
        return type(value) == "number" and (itemType == value or specializedItemType == value)
    end

    if typeMatches(ITEMTYPE_GLYPH_ARMOR)
        or typeMatches(ITEMTYPE_GLYPH_WEAPON)
        or typeMatches(ITEMTYPE_GLYPH_JEWELRY)
        or typeMatches(ITEMTYPE_BLACKSMITHING_MATERIAL)
        or typeMatches(ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)
        or typeMatches(ITEMTYPE_CLOTHIER_MATERIAL)
        or typeMatches(ITEMTYPE_CLOTHIER_RAW_MATERIAL)
        or typeMatches(ITEMTYPE_WOODWORKING_MATERIAL)
        or typeMatches(ITEMTYPE_WOODWORKING_RAW_MATERIAL)
        or typeMatches(ITEMTYPE_JEWELRYCRAFTING_MATERIAL)
        or typeMatches(ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)
        or typeMatches(ITEMTYPE_STYLE_MATERIAL)
        or typeMatches(ITEMTYPE_ARMOR_TRAIT)
        or typeMatches(ITEMTYPE_WEAPON_TRAIT)
        or typeMatches(ITEMTYPE_JEWELRY_RAW_TRAIT)
        or typeMatches(ITEMTYPE_JEWELRY_TRAIT)
        or typeMatches(ITEMTYPE_ALCHEMY_BASE)
        or typeMatches(ITEMTYPE_REAGENT)
        or typeMatches(ITEMTYPE_ENCHANTING_RUNE_ASPECT)
        or typeMatches(ITEMTYPE_ENCHANTING_RUNE_ESSENCE)
        or typeMatches(ITEMTYPE_ENCHANTING_RUNE_POTENCY) then
        return true
    end

    return false
end

function Greed:IsDropLogAntiquityLeadItem(itemLink, rawItemText)
    local itemType, specializedItemType = self:GetDropLogItemTypes(itemLink)

    local function typeMatches(value)
        return type(value) == "number" and (itemType == value or specializedItemType == value)
    end

    if typeMatches(ITEMTYPE_ANTIQUITY_LEAD)
        or typeMatches(SPECIALIZED_ITEMTYPE_TROPHY_ANTIQUITY_LEAD) then
        return true
    end

    local values = {}
    local function addText(value)
        if type(value) == "string" and value ~= "" then
            table.insert(values, value)
        end
    end

    addText(rawItemText)
    addText(itemLink)

    if type(itemLink) == "string" and itemLink ~= "" and type(GetItemLinkName) == "function" then
        local ok, itemName = pcall(function()
            return GetItemLinkName(itemLink)
        end)
        if ok and type(itemName) == "string" then
            addText(itemName)
        end
    end

    for _, value in ipairs(values) do
        if type(value) == "string" and value ~= "" then
            local clean = string.lower(self:GetCleanChatTextForDropLog(value))
            if clean:find("antiquity lead", 1, true) then
                return true
            end
        end
    end

    return false
end

function Greed:ShouldConsiderLootItemBeforeWishlist(itemLink, rawItemText)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false, nil, "missing item link"
    end

    if self:IsDropLogExcludedCraftingOrGlyphItem(itemLink) then
        return false, nil, "crafting/glyph/material"
    end

    if self:IsDropLogNormalQualityItem(itemLink) then
        return false, nil, "normal-quality item"
    end

    local lootInfo = self:GetLootSetInfo(itemLink)
    if lootInfo then
        return true, lootInfo, "set item"
    end

    if self:IsDropLogAntiquityLeadItem(itemLink, rawItemText) then
        return true, nil, "antiquity lead"
    end

    return false, nil, "generic non-set item"
end

function Greed:ShouldTrackDropLogItem(itemLink, match, lootInfo, preWishlistReason)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false, "missing item link"
    end

    if self:IsDropLogExcludedCraftingOrGlyphItem(itemLink) then
        return false, "crafting material or glyph"
    end

    if self:IsDropLogNormalQualityItem(itemLink) then
        return false, "normal-quality item"
    end

    if match then
        return true
    end

    if preWishlistReason == "antiquity lead" then
        return true
    end

    local setName = lootInfo and lootInfo.setName or ""
    if type(setName) ~= "string" or setName == "" then
        return false, "generic non-set item"
    end

    return true
end

function Greed:AddDropLogEntryFromItemLink(receivedBy, itemLink, quantity, isSelfLoot, itemId, rawItemText, source)
    if not self.savedVars or not self.savedVars.dropLog or not self:ShouldProcessDropLoot() then return false end

    local dropListEnabled = self.savedVars.dropLog.enabled == true

    if not isSelfLoot and self.savedVars.dropLog.trackGroupLoot == false then
        self:DropLogDebug("skipped other-player loot because Include other players' loot is OFF")
        return false
    end

    if not itemLink or itemLink == "" then
        self:DropLogDebug("skipped because item link could not be built")
        return false
    end

    local shouldConsider, lootInfo, gateReason = self:ShouldConsiderLootItemBeforeWishlist(itemLink, rawItemText)
    if not shouldConsider then
        if gateReason == "normal-quality item" then
            self:DropLogDebug("skipped early normal-quality item: " .. tostring(itemLink))
        elseif gateReason == "crafting/glyph/material" then
            self:DropLogDebug("skipped early crafting/glyph/material: " .. tostring(itemLink))
        elseif gateReason == "generic non-set item" then
            self:DropLogDebug("skipped early generic non-set item: " .. tostring(itemLink))
        else
            self:DropLogDebug("skipped early " .. tostring(gateReason or "filtered item") .. ": " .. tostring(itemLink))
        end
        return false
    end

    if gateReason == "set item" then
        self:DropLogDebug("allowed set item: " .. tostring(itemLink))
    elseif gateReason == "antiquity lead" then
        self:DropLogDebug("allowed antiquity lead: " .. tostring(itemLink))
    end

    local match = self:FindDropLogWishlistMatch(itemLink)
    local shouldTrackItem, skipReason = self:ShouldTrackDropLogItem(itemLink, match, lootInfo, gateReason)
    if not shouldTrackItem then
        self:DropLogDebug("skipped " .. tostring(skipReason or "filtered item") .. ": " .. tostring(itemLink))
        return false
    end

    if not dropListEnabled and not match then
        self:DropLogDebug("skipped non-wishlist item because Drop List window is disabled: " .. tostring(itemLink))
        return false
    end

    local isCollected, collectionKnown = nil, false
    local ownedCount, neededCount = nil, nil
    if match then
        isCollected, collectionKnown, ownedCount, neededCount = self:GetActualOwnedStateForDropMatch(match)
        if collectionKnown and isCollected == true and self.savedVars.dropLog.onlyMissing ~= false then
            self:DropLogDebug("wishlist display will hide already actually-owned item: " .. tostring(itemLink))
        end
    end

    local playerName = self:NormalizeLootRecipient(receivedBy, isSelfLoot)
    local displayName = self:GetLootRecipientDisplayName(receivedBy, playerName, isSelfLoot)
    local eventKey = tostring(playerName or receivedBy or "") .. "|" .. tostring(itemLink)
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    if self.lastDropLogEventKey == eventKey and (now - (self.lastDropLogEventTime or 0)) < 1200 then
        return true
    end
    self.lastDropLogEventKey = eventKey
    self.lastDropLogEventTime = now

    local traitName = self:GetTraitNameFromItemLink(itemLink)
    local itemName = self:GetDropLogItemDisplayText(itemLink, rawItemText, match)
    local slotKind = match and match.slotKind
    local slotKey = match and match.slotKey
    if not slotKind or not slotKey then
        slotKind, slotKey = self:GetLootSlotKeyFromItemLink(itemLink)
    end
    local slotLabel = match and match.slotLabel or self:GetDropSlotLabel(slotKind, slotKey)

    local entry = {
        receivedBy = playerName,
        rawReceivedBy = receivedBy or "",
        looterCharacterName = playerName,
        looterDisplayName = displayName,
        itemLink = itemLink,
        itemId = itemId,
        itemName = itemName,
        traitName = traitName,
        quantity = quantity or 1,
        selfLoot = isSelfLoot == true,
        wishlistMatched = match ~= nil,
        collected = isCollected == true,
        collectionKnown = collectionKnown == true,
        pageName = match and match.pageName or nil,
        matchedPages = match and match.matchedPages or nil,
        matchedPageList = match and match.matchedPageList or nil,
        setName = match and match.setName or (lootInfo and lootInfo.setName) or "",
        slotLabel = slotLabel,
        ownedCount = ownedCount,
        neededCount = neededCount,
        source = source or "event",
        timestamp = GetTimeStamp and GetTimeStamp() or 0,
        timestampText = GetTimeString and GetTimeString() or "",
    }

    if dropListEnabled then
        self:AddOrUpdateDropLogEntry(entry)
    end
    if entry.wishlistMatched == true then
        self:AddDropTextAlert(entry)
    end
    if dropListEnabled then
        self:ShowDropListWindow(false)
    end
    if entry.wishlistMatched then
        if dropListEnabled then
            SafeAnnounce(T("Greed: Wishlist drop logged - %s for %s.", entry.itemLink or entry.itemName, entry.receivedBy))
        else
            self:DropLogDebug("wishlist Drop Text alert shown while Drop List window is disabled: " .. tostring(entry.itemLink or entry.itemName))
        end
    else
        self:DropLogDebug("all-drop entry captured: " .. tostring(entry.itemLink or entry.itemName))
    end
    return true
end

function Greed:OnLootReceivedForDropLog(receivedBy, itemName, quantity, lootType, lootedBySelf, itemId)
    local isSelfLoot = lootedBySelf == true
    if lootType and LOOT_TYPE_ITEM and lootType ~= LOOT_TYPE_ITEM then
        if self.savedVars and self.savedVars.dropLog and self:ShouldProcessDropLoot() then
            self:DropLogDebug("skipped non-item lootType=" .. tostring(lootType))
        end
        return
    end

    local itemLink = self:ExtractLootItemLink(itemName, itemId)
    if isSelfLoot then
        self:RecordTradeLootEvent(itemLink, itemId, quantity)
    end

    if not self.savedVars or not self.savedVars.dropLog or not self:ShouldProcessDropLoot() then return end

    if not isSelfLoot and self.savedVars.dropLog.trackGroupLoot == false then
        return
    end

    self:DropLogDebug("source=event, receivedBy=" .. tostring(receivedBy or "") .. ", itemName=" .. tostring(itemName or "") .. ", lootedBySelf=" .. tostring(lootedBySelf == true) .. ", lootType=" .. tostring(lootType or "") .. ", itemId=" .. tostring(itemId or ""))

    self:AddDropLogEntryFromItemLink(receivedBy, itemLink, quantity, isSelfLoot, itemId, itemName, "event")
end

function Greed:BuildDropAskMessage(entry)
    local message = self.savedVars.dropLog.askMessage or DEFAULT_DROP_ASK_MESSAGE
    local itemText = entry.itemLink or entry.itemName or T("that item")
    local playerText = entry.receivedBy or T("there")
    local traitText = entry.traitName or ""

    message = message:gsub("{item}", itemText)
    message = message:gsub("{player}", playerText)
    message = message:gsub("{trait}", traitText)

    return message
end

function Greed:AskPlayerForDrop(entry)
    if not entry then return end

    if entry.selfLoot == true then
        SafeAnnounce(T("Greed: You looted this item."))
        return
    end

    self:StartDropWhisper(entry)
end
