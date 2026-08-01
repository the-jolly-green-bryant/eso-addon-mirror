Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local GreedData = Greed_Addon.Data
local T = Internal.T
local COLORS = Internal.COLORS
local WEAPON_ITEMS = Internal.WEAPON_ITEMS
local CallControlMethod = Internal.CallControlMethod
local SafeAnnounce = Internal.SafeAnnounce
local OWNED_INVENTORY_REFRESH_DELAY_MS = 100

function Greed:RefreshCollectionStatus()
    local mainVisible = self.controls and self.controls.window and not self.controls.window:IsHidden()
    local pickerVisible = type(self.HasVisiblePiecePickerWindow) == "function" and self:HasVisiblePiecePickerWindow()
    if not mainVisible and not pickerVisible then return end

    local ownedItemIndex = self:BuildOwnedItemIndex()
    if mainVisible then
        self:RefreshGridFromSaved(ownedItemIndex)
    end
    if pickerVisible and type(self.RefreshPiecePickerOwnershipStyles) == "function" then
        self:RefreshPiecePickerOwnershipStyles(ownedItemIndex)
    end
end

function Greed:IsOwnedInventoryBagSupported(bagId)
    if bagId == nil then return false end

    for _, ownedBagId in ipairs(self:GetOwnedBagIds()) do
        if bagId == ownedBagId then
            return true
        end
    end

    return false
end

function Greed:RefreshOwnedItemIndicators()
    local mainVisible = self.controls and self.controls.window and not self.controls.window:IsHidden()
    local pickerVisible = type(self.HasVisiblePiecePickerWindow) == "function" and self:HasVisiblePiecePickerWindow()
    if not mainVisible and not pickerVisible then
        self.ownedItemIndexDirty = true
        return
    end

    local ownedItemIndex = self:BuildOwnedItemIndex()
    self.ownedItemIndexDirty = mainVisible ~= true
    if mainVisible then
        self:RefreshGridFromSaved(ownedItemIndex)
    end
    if pickerVisible and type(self.RefreshPiecePickerOwnershipStyles) == "function" then
        self:RefreshPiecePickerOwnershipStyles(ownedItemIndex)
    end
end

function Greed:QueueOwnedItemIndicatorsRefresh()
    self.ownedItemIndexDirty = true
    if self.ownedInventoryRefreshPending == true then return end

    self.ownedInventoryRefreshPending = true
    local function refreshOwnedIndicators()
        self.ownedInventoryRefreshPending = false
        if self.ownedItemIndexDirty == true then
            self:RefreshOwnedItemIndicators()
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(refreshOwnedIndicators, OWNED_INVENTORY_REFRESH_DELAY_MS)
    else
        refreshOwnedIndicators()
    end
end

function Greed:OnOwnedInventorySlotUpdated(_, bagId, slotIndex)
    if not self:IsOwnedInventoryBagSupported(bagId) then return end

    if type(self.OnTradeLootInventorySlotUpdated) == "function" then
        self:OnTradeLootInventorySlotUpdated(bagId, slotIndex)
    end

    self:QueueOwnedItemIndicatorsRefresh()
end

function Greed:RegisterOwnedInventoryRefreshEvents()
    if self.ownedInventoryRefreshRegistered == true then return end
    if not EVENT_MANAGER or EVENT_INVENTORY_SINGLE_SLOT_UPDATE == nil then return end

    EVENT_MANAGER:RegisterForEvent(self.name .. "OwnedInventoryRefresh", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
        self:OnOwnedInventorySlotUpdated(...)
    end)
    self.ownedInventoryRefreshRegistered = true
end

function Greed:GetCollectionSlotFromItemLink(itemLink)
    if not itemLink or itemLink == "" or type(GetItemLinkItemSetCollectionSlot) ~= "function" then
        return nil
    end

    local ok, slot = pcall(function()
        return GetItemLinkItemSetCollectionSlot(itemLink)
    end)

    if ok and slot then
        return slot
    end

    return nil
end

function Greed:GetCollectionSetId(setData, itemLink)
    if setData and setData.setId then
        return setData.setId
    end

    if itemLink and itemLink ~= "" and type(GetItemLinkSetInfo) == "function" then
        local ok, hasSet, _, _, _, _, setId = pcall(function()
            return GetItemLinkSetInfo(itemLink, false)
        end)

        if ok and hasSet and setId and setId ~= 0 then
            return setId
        end
    end

    return nil
end

function Greed:GetItemIdFromLink(itemLink)
    if not itemLink or itemLink == "" or type(GetItemLinkItemId) ~= "function" then
        return nil
    end

    local ok, itemId = pcall(function()
        return GetItemLinkItemId(itemLink)
    end)

    if ok and type(itemId) == "number" and itemId > 0 then
        return itemId
    end

    return nil
end

function Greed:GetCollectionPieceIdForItem(setId, itemLink, collectionSlot)
    if not setId or type(GetNumItemSetCollectionPieces) ~= "function" or type(GetItemSetCollectionPieceInfo) ~= "function" then
        return nil
    end

    local desiredItemId = self:GetItemIdFromLink(itemLink)
    local okCount, pieceCount = pcall(function()
        return GetNumItemSetCollectionPieces(setId)
    end)

    if not okCount or type(pieceCount) ~= "number" or pieceCount <= 0 then
        return nil
    end

    for index = 1, pieceCount do
        local okInfo, pieceId, slot = pcall(function()
            return GetItemSetCollectionPieceInfo(setId, index)
        end)

        if okInfo and pieceId and pieceId ~= 0 then
            if collectionSlot and slot == collectionSlot then
                return pieceId
            end

            if desiredItemId and type(GetItemSetCollectionPieceItemLink) == "function" then
                local okLink, collectionItemLink = pcall(function()
                    return GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil)
                end)
                local collectionItemId = okLink and self:GetItemIdFromLink(collectionItemLink) or nil
                if collectionItemId and collectionItemId == desiredItemId then
                    return pieceId
                end
            end
        end
    end

    return nil
end

function Greed:IsPieceCollectedInStickerbook(setData, column, piece)
    if not piece then return nil, false end

    local itemLink = piece.itemLink
    if not itemLink or itemLink == "" then
        itemLink = self:ResolveItemLink(setData, column, piece)
    end

    local setId = self:GetCollectionSetId(setData, itemLink)
    if not setId then
        return nil, false
    end

    local collectionSlot = piece.collectionSlot or self:GetCollectionSlotFromItemLink(itemLink)
    piece.collectionSlot = collectionSlot

    if collectionSlot and type(IsItemSetCollectionSlotUnlocked) == "function" then
        local ok, isUnlocked = pcall(function()
            return IsItemSetCollectionSlotUnlocked(setId, collectionSlot)
        end)

        if ok and type(isUnlocked) == "boolean" then
            return isUnlocked, true
        end
    end

    local pieceId = piece.collectionPieceId or self:GetCollectionPieceIdForItem(setId, itemLink, collectionSlot)
    piece.collectionPieceId = pieceId

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

function Greed:IsPieceUnlockedInStickerbook(setData, column, piece)
    local isUnlocked, isKnown = self:IsPieceCollectedInStickerbook(setData, column, piece)
    if isKnown then
        return isUnlocked == true
    end

    return false
end

function Greed:GetOwnedBagIds()
    local bagIds = {}
    local seen = {}

    local function addBagByName(name)
        local bagId = _G and _G[name] or nil
        if type(bagId) == "number" and not seen[bagId] then
            seen[bagId] = true
            table.insert(bagIds, bagId)
        end
    end

    addBagByName("BAG_BACKPACK")
    addBagByName("BAG_WORN")
    addBagByName("BAG_BANK")
    addBagByName("BAG_SUBSCRIBER_BANK")

    for index = 1, 10 do
        addBagByName("BAG_HOUSE_BANK_" .. tostring(index))
    end
    for _, suffix in ipairs({ "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN" }) do
        addBagByName("BAG_HOUSE_BANK_" .. suffix)
    end

    return bagIds
end

function Greed:GetSafeBagSize(bagId)
    if type(GetBagSize) ~= "function" then return 0 end

    local ok, size = pcall(function()
        return GetBagSize(bagId)
    end)

    if ok and type(size) == "number" and size > 0 then
        return size
    end

    return 0
end

function Greed:GetSafeBagItemLink(bagId, slotIndex)
    if type(GetItemLink) ~= "function" then return nil end

    local ok, itemLink = pcall(function()
        return GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    end)

    if (not ok or not itemLink or itemLink == "") then
        ok, itemLink = pcall(function()
            return GetItemLink(bagId, slotIndex)
        end)
    end

    if ok and type(itemLink) == "string" and itemLink ~= "" then
        return itemLink
    end

    return nil
end

function Greed:GetSetIdFromItemLink(itemLink)
    if not itemLink or itemLink == "" or type(GetItemLinkSetInfo) ~= "function" then return nil end

    local ok, hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = pcall(function()
        return GetItemLinkSetInfo(itemLink, false)
    end)

    if ok and hasSet and type(setId) == "number" and setId > 0 then
        return setId
    end

    return nil
end

function Greed:GetEquipTypeFromItemLink(itemLink)
    if not itemLink or itemLink == "" or type(GetItemLinkEquipType) ~= "function" then return nil end

    local ok, equipType = pcall(function()
        return GetItemLinkEquipType(itemLink)
    end)

    if ok and type(equipType) == "number" and equipType > 0 then
        return equipType
    end

    return nil
end

function Greed:GetWeaponTypeFromItemLink(itemLink)
    if not itemLink or itemLink == "" or type(GetItemLinkWeaponType) ~= "function" then return nil end

    local ok, weaponType = pcall(function()
        return GetItemLinkWeaponType(itemLink)
    end)

    if ok and type(weaponType) == "number" and weaponType > 0 then
        return weaponType
    end

    return nil
end

function Greed:GetOwnedItemName(itemLink)
    if itemLink and type(GetItemLinkName) == "function" then
        local ok, itemName = pcall(function()
            return GetItemLinkName(itemLink)
        end)

        if ok and type(itemName) == "string" and itemName ~= "" then
            return self:CleanEsoDisplayText(itemName)
        end
    end

    return itemLink or "Unknown Item"
end

function Greed:GetEquipTypeDebugName(equipType)
    for _, slot in ipairs(GreedData.armorSlots or {}) do
        if slot.equipType == equipType then
            return slot.label
        end
    end

    return tostring(equipType or "nil")
end

function Greed:GetWeaponTypeDebugName(weaponType)
    for _, weapon in ipairs(WEAPON_ITEMS) do
        if weapon.weaponType == weaponType then
            return weapon.label
        end
    end

    return tostring(weaponType or "nil")
end

function Greed:GetOwnedMatchTarget(setData, column, piece)
    local target = {
        setId = self:GetLibSetsSetId(setData),
        itemName = self:GetTrackedDisplayItemName(setData, column, piece),
        kind = column and column.kind or nil,
        slotKey = column and column.key or nil,
    }

    if column and column.kind == "weapon" then
        local weaponType = self:GetWeaponType(piece)
        target.weaponType = column.weaponType or weaponType.weaponType
        target.typeLabel = weaponType.label
    elseif column then
        target.equipType = column.equipType
        target.typeLabel = column.label
    end

    return target
end

function Greed:GetOwnedItemIndexKey(kind, setId, typeId)
    if not kind or not setId or not typeId then return nil end
    return tostring(kind) .. "|" .. tostring(setId) .. "|" .. tostring(typeId)
end

function Greed:AddOwnedItemIndexEntry(index, kind, setId, typeId, itemLink, bagId, slotIndex)
    local key = self:GetOwnedItemIndexKey(kind, setId, typeId)
    if not key then return end

    index[key] = index[key] or {}
    table.insert(index[key], {
        itemLink = itemLink,
        bagId = bagId,
        slotIndex = slotIndex,
    })
end

function Greed:BuildOwnedItemIndex()
    local index = {}

    for _, bagId in ipairs(self:GetOwnedBagIds()) do
        local bagSize = self:GetSafeBagSize(bagId)
        if bagSize > 0 then
            for slotIndex = 0, bagSize - 1 do
                local itemLink = self:GetSafeBagItemLink(bagId, slotIndex)
                if itemLink then
                    local itemSetId = self:GetSetIdFromItemLink(itemLink)
                    if itemSetId then
                        local weaponType = self:GetWeaponTypeFromItemLink(itemLink)
                        if weaponType then
                            self:AddOwnedItemIndexEntry(index, "weapon", itemSetId, weaponType, itemLink, bagId, slotIndex)
                        end

                        local equipType = self:GetEquipTypeFromItemLink(itemLink)
                        if equipType then
                            self:AddOwnedItemIndexEntry(index, "equip", itemSetId, equipType, itemLink, bagId, slotIndex)
                        end
                    end
                end
            end
        end
    end

    return index
end

function Greed:NormalizeItemNameForCompare(itemName)
    local text = self:CleanEsoDisplayText(itemName or "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return string.lower(text)
end

function Greed:AddOwnedMatchResult(result, itemName, itemLink, bagId, slotIndex, reason)
    result.count = (result.count or 0) + 1
    result.matches = result.matches or {}
    table.insert(result.matches, {
        itemName = itemName,
        itemLink = itemLink,
        bagId = bagId,
        slotIndex = slotIndex,
        reason = reason,
    })
end

function Greed:StoreOwnedMatchResult(piece, result)
    if not piece then return end

    piece.matchedOwnedItemNames = {}
    piece.matchedOwnedItemLinks = {}
    piece.matchedOwnedItemDetails = {}

    for _, match in ipairs(result.matches or {}) do
        table.insert(piece.matchedOwnedItemNames, match.itemName)
        table.insert(piece.matchedOwnedItemLinks, match.itemLink)
        table.insert(piece.matchedOwnedItemDetails, match)
    end

    piece.lastOwnedCountResult = result
end

function Greed:DebugOwnedMatch(target, itemName, reasonLines)
    if not self.ownedDebug then return end

    SafeAnnounce(string.format("Matched %s as %s because:", itemName or "Unknown Item", target.itemName or "tracked item"))
    for _, line in ipairs(reasonLines or {}) do
        SafeAnnounce("- " .. line)
    end
end

function Greed:DebugOwnedSkip(target, itemName, reason)
    if not self.ownedDebug then return end

    SafeAnnounce(string.format("Skipped %s because %s.", itemName or "Unknown Item", reason or "it did not match"))
end

function Greed:CountOwnedMatchingItems(setData, column, piece, neededCount, ownedItemIndex)
    local target = self:GetOwnedMatchTarget(setData, column, piece)
    local result = {
        count = 0,
        target = target,
        matches = {},
    }

    if not target.setId then
        if self.ownedDebug then
            SafeAnnounce("Greed owned debug: no target setId for " .. tostring(target.itemName or "tracked item") .. ".")
        end
        self:StoreOwnedMatchResult(piece, result)
        return 0, result
    end

    ownedItemIndex = ownedItemIndex or self:BuildOwnedItemIndex()

    local matchKind
    local matchType
    local reason
    local debugTypeName
    if target.kind == "weapon" then
        matchKind = "weapon"
        matchType = target.weaponType
        debugTypeName = self:GetWeaponTypeDebugName(target.weaponType)
        reason = "same setId + same weaponType " .. debugTypeName
    else
        matchKind = "equip"
        matchType = target.equipType
        debugTypeName = self:GetEquipTypeDebugName(target.equipType)
        reason = "same setId + same equipType " .. debugTypeName
    end

    local key = self:GetOwnedItemIndexKey(matchKind, target.setId, matchType)
    for _, match in ipairs((key and ownedItemIndex[key]) or {}) do
        local itemName = match.itemName or self:GetOwnedItemName(match.itemLink)
        match.itemName = itemName
        self:AddOwnedMatchResult(result, itemName, match.itemLink, match.bagId, match.slotIndex, reason)
        if target.kind == "weapon" then
            self:DebugOwnedMatch(target, itemName, { "same setId", "same weaponType " .. debugTypeName })
        else
            self:DebugOwnedMatch(target, itemName, { "same setId", "same equipType " .. debugTypeName })
        end
    end

    local cappedCount = math.min(result.count or 0, neededCount or result.count or 0)
    result.cappedCount = cappedCount
    self:StoreOwnedMatchResult(piece, result)

    if self.ownedDebug then
        SafeAnnounce(string.format("Greed owned debug: %s final owned count %d/%d.", target.itemName or "tracked item", cappedCount, neededCount or 1))
    end

    return cappedCount, result
end

function Greed:GetPieceCounts(column, piece, setData, ownedItemIndex)
    local needed = 1

    if column.key == "ring" then
        needed = piece.total or column.total or 2
    end

    local actualOwnedCount = self:CountOwnedMatchingItems(setData, column, piece, needed, ownedItemIndex)
    return math.min(actualOwnedCount or 0, needed), needed
end

function Greed:GetDifferentOwnedItemNames(setData, column, piece)
    local names = {}
    local seen = {}
    local trackedName = self:NormalizeItemNameForCompare(self:GetTrackedDisplayItemName(setData, column, piece))

    for _, itemName in ipairs(piece and piece.matchedOwnedItemNames or {}) do
        local comparableName = self:NormalizeItemNameForCompare(itemName)
        if comparableName ~= "" and comparableName ~= trackedName and not seen[comparableName] then
            seen[comparableName] = true
            table.insert(names, itemName)
        end
    end

    return names
end

function Greed:PrintOwnedWhySummary(setData, column, piece, collectedCount, neededCount)
    local result = piece and piece.lastOwnedCountResult or nil
    local targetName = self:GetTrackedDisplayItemName(setData, column, piece)

    SafeAnnounce("Greed owned why: " .. targetName)
    SafeAnnounce(string.format("owned count = %d/%d", collectedCount or 0, neededCount or 1))

    if not result or not result.matches or #result.matches == 0 then
        SafeAnnounce("matched owned items = none")
        return
    end

    local names = {}
    for _, match in ipairs(result.matches) do
        table.insert(names, match.itemName or "Unknown Item")
    end

    SafeAnnounce("matched owned items = " .. table.concat(names, ", "))
    for _, match in ipairs(result.matches) do
        SafeAnnounce("why = " .. (match.reason or "strict set/type match"))
    end
end

function Greed:ShowSlotTooltip(control, setData, column, piece, collectedCount, neededCount, stickerBookUnlocked)
    InitializeTooltip(InformationTooltip, control, TOP, 0, -8)
    CallControlMethod(InformationTooltip, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(InformationTooltip, "SetDrawTier", DT_HIGH)
    CallControlMethod(InformationTooltip, "SetDrawLevel", 4000)
    CallControlMethod(InformationTooltip, "BringWindowToTop")

    InformationTooltip:AddLine(self:GetDisplayItemName(setData, column, piece), "ZoFontGameBold", COLORS.text[1], COLORS.text[2], COLORS.text[3], CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    InformationTooltip:AddLine(T("Set: %s", self:CleanEsoDisplayText(setData.name)), "ZoFontGame", COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    if column.kind == "weapon" then
        local weaponType = self:GetWeaponType(piece)
        InformationTooltip:AddLine(T("Weapon Type: %s", weaponType.label), "ZoFontGame", COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    else
        InformationTooltip:AddLine(T("Slot: %s", column.label), "ZoFontGame", COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    end

    if self:IsMonsterSetData(setData) then
        InformationTooltip:AddLine(T("Needs: %s", self:GetMonsterWeightNeedsText(setData)), "ZoFontGameSmall", 1, 0.92, 0.74, 1)
    end

    local statusText = collectedCount >= neededCount and T("Have") or T("Need")
    InformationTooltip:AddLine(T("Status: %s", statusText), "ZoFontGameSmall", 1, 0.92, 0.74, 1)
    InformationTooltip:AddLine(T("Owned: %d/%d", collectedCount or 0, neededCount or 1), "ZoFontGameSmall", COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local differentOwnedNames = self:GetDifferentOwnedItemNames(setData, column, piece)
    if #differentOwnedNames > 0 then
        InformationTooltip:AddLine(T("Owned Item: %s", table.concat(differentOwnedNames, ", ")), "ZoFontGameSmall", 1, 0.92, 0.74, 1)
    end

    if stickerBookUnlocked == nil then
        stickerBookUnlocked = self:IsPieceUnlockedInStickerbook(setData, column, piece) == true
    end
    if stickerBookUnlocked then
        InformationTooltip:AddLine(T("Sticker Book: Unlocked"), "ZoFontGameSmall", COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], COLORS.gold[4])
    end

    InformationTooltip:AddLine(T("Source: %s", self:CleanEsoDisplayText(setData.source)), "ZoFontGameSmall", COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    if piece.iconResolutionFailed then
        InformationTooltip:AddLine(T("Icon: marked fallback"), "ZoFontGameSmall", 1, 0.45, 0.40, 1)
    end
    CallControlMethod(InformationTooltip, "SetDrawLevel", 4000)
    CallControlMethod(InformationTooltip, "BringWindowToTop")

    if self.ownedWhyDebug then
        self:PrintOwnedWhySummary(setData, column, piece, collectedCount, neededCount)
    end
end

function Greed:GetStatusText(collectedCount, neededCount)
    local status = collectedCount >= neededCount and T("Have") or T("Need")
    if neededCount and neededCount > 1 then
        return string.format("%s (%d/%d)", status, collectedCount or 0, neededCount)
    end

    return status
end

function Greed:GetTrackedDisplayItemName(setData, column, piece)
    if column.kind == "weapon" then
        local weaponType = self:GetWeaponType(piece)
        local itemName = (setData.baseName or setData.name) .. " " .. weaponType.label
        if piece and piece.perfected then
            itemName = T("Perfected %s", itemName)
        end
        return self:CleanEsoDisplayText(itemName)
    end

    local itemName = (setData.baseName or setData.name) .. " " .. column.label
    if piece and piece.perfected then
        itemName = T("Perfected %s", itemName)
    end
    return self:CleanEsoDisplayText(itemName)
end

function Greed:GetDisplayItemName(setData, column, piece)
    if piece.itemName then
        return self:CleanEsoDisplayText(piece.itemName)
    end

    if column.kind == "weapon" then
        local weaponType = self:GetWeaponType(piece)
        local itemName = setData.name .. " " .. weaponType.label
        if piece.perfected then
            itemName = T("Perfected %s", itemName)
        end
        return self:CleanEsoDisplayText(itemName)
    end

    local itemName = setData.name .. " " .. column.label
    if piece.perfected then
        itemName = T("Perfected %s", itemName)
    end
    return self:CleanEsoDisplayText(itemName)
end
