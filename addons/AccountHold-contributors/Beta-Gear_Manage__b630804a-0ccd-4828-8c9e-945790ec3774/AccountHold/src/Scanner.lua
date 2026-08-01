-- Quartermaster/src/Scanner.lua
-- Walks every container the account touches and writes entries into the
-- account-wide index in SavedVariables. Diff-applies EVENT_INVENTORY_SINGLE_SLOT_UPDATE
-- so we don't re-walk a 200-slot bag on every stack change.
--
-- API contract per entry:
--   {
--     itemSignature = string,   -- normalized link (no count)
--     itemLink      = string,   -- raw link for display
--     name          = string,
--     icon          = string,
--     stackCount    = number,
--     quality       = number,
--     itemType      = number,   -- ITEMTYPE_*
--     setId         = number?,  -- if part of a set
--     traitType     = number?,
--     equipType     = number?,
--     requiredLevel = number?,
--     requiredChampionPoints = number?,
--     specializedItemType = number?,
--     bindType      = number,   -- BIND_TYPE_*
--     isCharacterBound = bool,
--     uniqueId      = string?,  -- when GetItemUniqueId is meaningful
--     scannedAt     = number,
--   }

AccountHold = AccountHold or {}
AccountHold.Scanner = AccountHold.Scanner or {}

local Scanner = AccountHold.Scanner
local addon                                  -- set in Initialize

-- ---------------------------------------------------------------------------
-- Bag enumeration
-- ---------------------------------------------------------------------------

-- House-storage bag IDs. ESO exposes BAG_HOUSE_BANK_ONE..TEN as globals; we
-- collect any that resolve to a number at runtime so the addon stays correct
-- even if ZOS adds slots later.
local function houseBags()
    local bags = {}
    local names = {
        "BAG_HOUSE_BANK_ONE",  "BAG_HOUSE_BANK_TWO",  "BAG_HOUSE_BANK_THREE",
        "BAG_HOUSE_BANK_FOUR", "BAG_HOUSE_BANK_FIVE", "BAG_HOUSE_BANK_SIX",
        "BAG_HOUSE_BANK_SEVEN","BAG_HOUSE_BANK_EIGHT","BAG_HOUSE_BANK_NINE",
        "BAG_HOUSE_BANK_TEN",
    }
    for _, n in ipairs(names) do
        local v = _G[n]
        if type(v) == "number" then table.insert(bags, v) end
    end
    return bags
end

local function isHouseBag(bagId)
    for _, b in ipairs(houseBags()) do
        if b == bagId then return true end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Item entry construction
-- ---------------------------------------------------------------------------

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

-- Two-return variant. Several ESO accessors return a PAIR and the second value
-- is the one we need -- GetItemType(bag, slot) and GetItemLinkItemType(link)
-- both return (itemType, specializedItemType). safeCall above captures only the
-- first result from pcall, which silently discarded every specialized type.
local function safeCall2(fn, ...)
    if type(fn) ~= "function" then return nil, nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
    return nil, nil
end

-- Localized trait label for a trait enum, via the game's SI_ITEMTRAITTYPE
-- string enum (same call shape Index:GetKnownWeaponTypes uses for
-- SI_WEAPONTYPE). This MUST be resolved at scan time: the Trait column and the
-- Trait sort in ui/InventoryTab_Keyboard.lua, plus Index:GetKnownTraits and the
-- filter.traitName match in Index:Query, all key off entry.traitName. Storing
-- only the numeric traitType left every one of them looking at nil, so the
-- Trait dropdown came up empty and sorting by Trait was a no-op.
-- ITEM_TRAIT_TYPE_NONE (0) stays nil so untraited items sort as "no trait".
local function traitNameFor(traitType)
    if type(traitType) ~= "number" or traitType == 0 then return nil end
    local label = safeCall(GetString, "SI_ITEMTRAITTYPE", traitType)
    if type(label) == "string" and label ~= "" then return label end
    return nil
end

local function buildEntry(bagId, slotIndex)
    local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    if not link or link == "" then return nil end

    local name        = GetItemName(bagId, slotIndex)
    local icon, stackCount, _, _, _, _, _, _ = GetItemInfo(bagId, slotIndex)
    local quality     = GetItemLinkFunctionalQuality and GetItemLinkFunctionalQuality(link)
                        or (GetItemLinkQuality and GetItemLinkQuality(link))
                        or 0
    -- GetItemType returns TWO values: itemType AND specializedItemType (see
    -- ESOUIDocumentation.txt, and esoui/ingame/inventory/sharedinventory.lua:
    -- `slot.itemType, slot.specializedItemType = GetItemType(bagId, slotIndex)`).
    -- Capturing only the first is why every furnishing sub-type filter returned
    -- nothing: `GetItemLinkSpecializedItemType` -- which this used to call --
    -- DOES NOT EXIST in the ESO API, so safeCall's `type(fn) ~= "function"`
    -- guard silently returned nil and the field was never populated.
    local itemType, specType = safeCall2(GetItemType, bagId, slotIndex)
    -- Link-based fallback, also multi-return: GetItemLinkItemType(link)
    -- returns itemType, specializedItemType.
    if specType == nil then
        local _, spec = safeCall2(GetItemLinkItemType, link)
        specType = spec
    end
    local equipType   = safeCall(GetItemLinkEquipType, link)
    local traitType   = safeCall(GetItemLinkTraitType, link)
    local armorType   = safeCall(GetItemLinkArmorType, link)
    local weaponType  = safeCall(GetItemLinkWeaponType, link)
    local reqLevel    = safeCall(GetItemLinkRequiredLevel, link)
    local reqCP       = safeCall(GetItemLinkRequiredChampionPoints, link)
    local bindType    = safeCall(GetItemLinkBindType, link) or 0
    -- The ONLY thing distinguishing companion gear from the player's own — it
    -- carries identical ITEMTYPE_* values. Mirrors sharedinventory.lua's
    -- `slot.actorCategory = GetItemActorCategory(bagId, slotIndex)`. safeCall
    -- no-ops when the API is absent, and Index falls back to the item link.
    local actorCategory = safeCall(GetItemActorCategory, bagId, slotIndex)
    if type(actorCategory) ~= "number" then
        actorCategory = safeCall(GetItemLinkActorCategory, link)
    end
    if type(actorCategory) ~= "number" then actorCategory = nil end
    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(link, false)
    local uniqueId    = safeCall(GetItemUniqueId, bagId, slotIndex)

    -- "Character bound" detection: BIND_TYPE_ON_PICKUP_BACKPACK plus the item
    -- having a non-zero IsItemBoundToCharacter response. The item's bind state
    -- is what matters at retrieval time; we stash it for the UI.
    local isCharacterBound = false
    if IsItemBoundToCharacter then
        isCharacterBound = IsItemBoundToCharacter(bagId, slotIndex) and true or false
    end

    return {
        itemSignature    = link,                     -- raw link is itself the signature ESO uses
        itemLink         = link,
        name             = name or "",
        icon             = icon or "",
        stackCount       = stackCount or 0,
        quality          = quality,
        itemType         = itemType or 0,
        setId            = hasSet and setId or nil,
        setName          = hasSet and setName or nil,
        traitType        = traitType,
        traitName        = traitNameFor(traitType),
        equipType        = equipType,
        armorType        = armorType,
        weaponType       = weaponType,
        requiredLevel    = reqLevel,
        requiredChampionPoints = reqCP,
        specializedItemType = specType,
        actorCategory    = actorCategory,
        bindType         = bindType,
        isCharacterBound = isCharacterBound,
        uniqueId         = uniqueId,
        scannedAt        = GetTimeStamp(),
    }
end

-- ---------------------------------------------------------------------------
-- Bag walk
-- ---------------------------------------------------------------------------

local function walkBag(bagId, sink)
    local size = GetBagSize(bagId)
    for slot = 0, (size or 0) - 1 do
        if not IsItemBagAndSlotEmpty or not IsItemBagAndSlotEmpty(bagId, slot) then
            local entry = buildEntry(bagId, slot)
            if entry then sink[slot] = entry end
        end
    end
end

-- Exposed for other modules (Index live craft-bag walk uses this).
Scanner._BuildEntry = buildEntry

-- ---------------------------------------------------------------------------
-- Post-scan hooks
-- ---------------------------------------------------------------------------

-- After ANY full scan completes, the candidate snapshots stored on existing
-- holds are stale (the freshly-found items may belong to a holder we now know
-- about, or items we previously tracked may be gone). Refresh them so the
-- brief §8 state machine — "(scan finds item on holder character)──>
-- [awaiting_deposit]" — can advance promptly. Cheap operation: the holds map
-- is bounded by the user's holdRetentionDays setting (1..30, default 7).
local function refreshHoldsAfterScan()
    if not (addon and addon.sv and addon.sv.holds and addon.Holds) then return end
    if addon.Holds.RefreshAllCandidates then
        addon.Holds:RefreshAllCandidates()
    end
    -- A scan that discovers a non-bound candidate on a non-active character
    -- should promote OPEN holds to AWAITING_DEPOSIT (brief §8). Holds:Create
    -- does this on creation; we replicate it here for existing holds.
    local me = addon:GetCharacterId()
    for _, hold in pairs(addon.sv.holds) do
        if hold.status == addon.Holds.STATE_OPEN then
            for _, c in ipairs(hold.candidates or {}) do
                if not c.isCharacterBound and c.characterId and c.characterId ~= me then
                    hold.status    = addon.Holds.STATE_AWAITING_DEPOSIT
                    hold.updatedAt = GetTimeStamp()
                    break
                end
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Per-container scans
-- ---------------------------------------------------------------------------

-- Announce a completed scan. When the announceScanResults setting is on we
-- print a visible chat line; otherwise the result is only recorded via Debug
-- (which itself respects debugLogging). This lets players who want quiet
-- operation suppress the "scan complete: N items" spam while still surfacing
-- it on demand.
function Scanner:_report(fmt, ...)
    if addon.sv and addon.sv.settings and addon.sv.settings.announceScanResults then
        addon:Log(fmt, ...)
    else
        addon:Debug(fmt, ...)
    end
end

function Scanner:ScanCharacter()
    local rec = addon:GetCharacterRecord()
    rec.backpack = {}
    walkBag(BAG_BACKPACK, rec.backpack)
    rec.worn = {}
    walkBag(BAG_WORN, rec.worn)
    rec.lastFullScan = GetTimeStamp()
    self:_report("Character scan complete: backpack=%d worn=%d",
        self:_count(rec.backpack), self:_count(rec.worn))
    if addon.Index and addon.Index.Invalidate then addon.Index:Invalidate() end
    refreshHoldsAfterScan()
end

function Scanner:ScanAccountBank()
    local target = addon.sv.accountBank
    target.items = {}
    walkBag(BAG_BANK, target.items)
    -- ESO Plus tier piles into the same logical bank but uses a separate
    -- bagId. Merge it under the same store with a slot prefix so keys stay
    -- unique.
    if BAG_SUBSCRIBER_BANK then
        local subSize = GetBagSize(BAG_SUBSCRIBER_BANK) or 0
        for slot = 0, subSize - 1 do
            if not IsItemBagAndSlotEmpty or not IsItemBagAndSlotEmpty(BAG_SUBSCRIBER_BANK, slot) then
                local entry = buildEntry(BAG_SUBSCRIBER_BANK, slot)
                if entry then
                    entry._subscriber = true
                    target.items[string.format("S:%d", slot)] = entry
                end
            end
        end
    end
    target.lastFullScan = GetTimeStamp()
    self:_report("Account bank scan complete: %d entries", self:_count(target.items))
    if addon.Index and addon.Index.Invalidate then addon.Index:Invalidate() end
    refreshHoldsAfterScan()
end

function Scanner:ScanGuildBank(guildId)
    if not guildId or guildId == 0 then return end
    local store = addon.sv.guildBanks[guildId] or { items = {} }
    store.name  = GetGuildName(guildId) or store.name or "?"
    store.items = {}
    walkBag(BAG_GUILDBANK, store.items)
    store.lastFullScan = GetTimeStamp()
    addon.sv.guildBanks[guildId] = store
    self:_report("Guild bank scan complete (%s): %d entries", store.name, self:_count(store.items))
    if addon.Index and addon.Index.Invalidate then addon.Index:Invalidate() end
    refreshHoldsAfterScan()
end

function Scanner:ScanHouseStorage(bagId)
    if not isHouseBag(bagId) then return end
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or 0
    if houseId == 0 then return end

    addon.sv.houseStorage[houseId] = addon.sv.houseStorage[houseId] or {}
    local houseBucket = addon.sv.houseStorage[houseId]
    houseBucket[bagId] = { items = {} }
    walkBag(bagId, houseBucket[bagId].items)
    houseBucket[bagId].lastFullScan = GetTimeStamp()
    self:_report("House storage scan complete (house=%d bag=%d): %d entries",
        houseId, bagId, self:_count(houseBucket[bagId].items))
    if addon.Index and addon.Index.Invalidate then addon.Index:Invalidate() end
    refreshHoldsAfterScan()
end

-- Force a re-index on demand (Settings "Scan now" button). Always re-scans the
-- current character (always addressable). Any container the player currently
-- has open is re-scanned too; we deliberately do NOT touch closed containers,
-- because their slots are unreadable when away and a blind walk would wipe the
-- stored snapshot.
function Scanner:ScanAll()
    self:ScanCharacter()
    local openBag = self._openBankBag
    if openBag then
        if openBag == BAG_BANK or (BAG_SUBSCRIBER_BANK and openBag == BAG_SUBSCRIBER_BANK) then
            self:ScanAccountBank()
        elseif isHouseBag(openBag) then
            self:ScanHouseStorage(openBag)
        end
    end
    if self._currentGuildBankId and self._currentGuildBankId ~= 0 then
        self:ScanGuildBank(self._currentGuildBankId)
    end
    -- Route the completion notice through _report so it honours the
    -- announceScanResults setting like every other scan message. It used to
    -- call addon:Log directly, which printed to chat even with announcements
    -- switched OFF -- the "I turned it off and it still talks to me" bug.
    self:_report("%s: OK", GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_NOW))
end

-- ---------------------------------------------------------------------------
-- Slot-update diffs (cheap path)
-- ---------------------------------------------------------------------------

local function updateOne(bucket, bagId, slotIndex)
    if not bucket then return end
    if IsItemBagAndSlotEmpty and IsItemBagAndSlotEmpty(bagId, slotIndex) then
        bucket[slotIndex] = nil
    else
        local entry = buildEntry(bagId, slotIndex)
        bucket[slotIndex] = entry
    end
end

function Scanner:OnSlotUpdate(bagId, slotIndex)
    -- Do NOT do per-slot work while a crafting/deconstruction station is open.
    -- Deconstructing or refining a full bag fires this once per item; rebuilding
    -- an item link + touching the index each time is pure churn that the player
    -- feels as lag "caused" by the addon during crafting. Instead we remember
    -- that our character bags changed and do ONE rescan when the station closes
    -- (EVENT_END_CRAFTING_STATION_INTERACT).
    if type(ZO_CraftingUtils_IsCraftingWindowOpen) == "function"
       and ZO_CraftingUtils_IsCraftingWindowOpen() then
        if bagId == BAG_BACKPACK or bagId == BAG_WORN then
            self._pendingCharRescan = true
        end
        return
    end
    if bagId == BAG_BACKPACK then
        updateOne(addon:GetCharacterRecord().backpack, bagId, slotIndex)
    elseif bagId == BAG_WORN then
        updateOne(addon:GetCharacterRecord().worn, bagId, slotIndex)
    elseif bagId == BAG_BANK then
        updateOne(addon.sv.accountBank.items, bagId, slotIndex)
    elseif BAG_SUBSCRIBER_BANK and bagId == BAG_SUBSCRIBER_BANK then
        local key = string.format("S:%d", slotIndex)
        if IsItemBagAndSlotEmpty and IsItemBagAndSlotEmpty(bagId, slotIndex) then
            addon.sv.accountBank.items[key] = nil
        else
            local entry = buildEntry(bagId, slotIndex)
            if entry then entry._subscriber = true end
            addon.sv.accountBank.items[key] = entry
        end
    elseif bagId == BAG_GUILDBANK then
        -- P2 #17: a slot update can race with EVENT_CLOSE_GUILD_BANK clearing
        -- _currentGuildBankId. Keep a short-lived buffer so the diff doesn't
        -- silently drop on the close→reopen edge.
        local guildId = self._currentGuildBankId or self._lastGuildBankId or 0
        if guildId ~= 0 and addon.sv.guildBanks[guildId] then
            updateOne(addon.sv.guildBanks[guildId].items, bagId, slotIndex)
        end
    elseif isHouseBag(bagId) then
        local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or 0
        local bucket  = addon.sv.houseStorage[houseId] and addon.sv.houseStorage[houseId][bagId]
        if bucket then updateOne(bucket.items, bagId, slotIndex) end
    end
    if addon.Index and addon.Index.Invalidate then addon.Index:Invalidate() end
end

-- ---------------------------------------------------------------------------
-- Throttling
-- ---------------------------------------------------------------------------

local function minutesSince(ts)
    if not ts or ts == 0 then return math.huge end
    return (GetTimeStamp() - ts) / 60
end

function Scanner:MaybeFullScanCharacter()
    local rec = addon:GetCharacterRecord()
    if minutesSince(rec.lastFullScan) >= addon.sv.settings.scanIntervalMinutes then
        self:ScanCharacter()
    end
end

-- ---------------------------------------------------------------------------
-- Event wiring
-- ---------------------------------------------------------------------------

function Scanner:Initialize(addonRef)
    addon = addonRef

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        function(_, isInitialActivation)
            if addon.sv.settings.scanOnLogin then
                self:ScanCharacter()
                -- Account bank items are not addressable until the player
                -- opens the bank, so we don't rescan on activation.
            else
                self:MaybeFullScanCharacter()
            end
            if addon.Notify and addon.Notify.OnPlayerActivated then
                addon.Notify:OnPlayerActivated(isInitialActivation)
            end
        end)

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_SlotUpdate",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotIndex)
            self:OnSlotUpdate(bagId, slotIndex)
        end)

    -- Flush the deferred character rescan when a crafting station closes. See
    -- OnSlotUpdate: while a station is open we skip per-slot work entirely, so
    -- this single rescan reconciles everything that changed in one pass.
    if EVENT_END_CRAFTING_STATION_INTERACT then
        EVENT_MANAGER:RegisterForEvent(addon.name .. "_CraftEnd",
            EVENT_END_CRAFTING_STATION_INTERACT,
            function()
                if self._pendingCharRescan then
                    self._pendingCharRescan = nil
                    self:ScanCharacter()
                end
            end)
    end

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_OpenBank",
        EVENT_OPEN_BANK,
        function(_, bankBag)
            self._openBankBag = bankBag
            if bankBag == BAG_BANK or (BAG_SUBSCRIBER_BANK and bankBag == BAG_SUBSCRIBER_BANK) then
                if addon.sv.settings.scanOnBankOpen ~= false then
                    self:ScanAccountBank()
                end
            elseif isHouseBag(bankBag) then
                if addon.sv.settings.scanOnHouseStorageOpen ~= false then
                    self:ScanHouseStorage(bankBag)
                end
            end
            if addon.UI and addon.UI.OnContainerOpened then
                addon.UI:OnContainerOpened(bankBag)
            end
        end)

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_CloseBank",
        EVENT_CLOSE_BANK,
        function()
            self._openBankBag = nil
            if addon.UI and addon.UI.OnContainerClosed then
                addon.UI:OnContainerClosed("bank")
            end
        end)

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_GuildBankSelected",
        EVENT_GUILD_BANK_SELECTED,
        function(_, guildId)
            self._currentGuildBankId = guildId
            self._lastGuildBankId    = guildId
        end)

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_GuildBankReady",
        EVENT_GUILD_BANK_ITEMS_READY,
        function()
            local guildId = self._currentGuildBankId or 0
            if guildId ~= 0 then
                if addon.sv.settings.scanOnGuildBankOpen ~= false then
                    self:ScanGuildBank(guildId)
                end
                if addon.UI and addon.UI.OnContainerOpened then
                    addon.UI:OnContainerOpened(BAG_GUILDBANK)
                end
            end
        end)

    EVENT_MANAGER:RegisterForEvent(addon.name .. "_GuildBankClose",
        EVENT_CLOSE_GUILD_BANK,
        function()
            -- Keep _lastGuildBankId so a slot-update racing the close still
            -- targets the right SV bucket (P2 #17). Schedule a clear so the
            -- buffer doesn't outlive the actual transition.
            self._currentGuildBankId = nil
            if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
                local key = addon.name .. "_GuildBankBufferClear"
                EVENT_MANAGER:UnregisterForUpdate(key)
                EVENT_MANAGER:RegisterForUpdate(key, 5000, function()
                    self._lastGuildBankId = nil
                    EVENT_MANAGER:UnregisterForUpdate(key)
                end)
            end
            if addon.UI and addon.UI.OnContainerClosed then
                addon.UI:OnContainerClosed("guildbank")
            end
        end)
end

-- ---------------------------------------------------------------------------
-- Internals
-- ---------------------------------------------------------------------------

function Scanner:_count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end
