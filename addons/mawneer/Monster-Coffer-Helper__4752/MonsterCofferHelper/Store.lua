local MCH = MonsterCofferHelper

local Store = {}
MCH.Store = Store

-- What the last store scan found. Cleared when the store closes.
-- { vendorId, mysteryIndex, curatedIndexToSetId = { [storeIndex] = setId } }
Store.current = nil

--------------------------------------------------------------------------------
-- Matching store entries to sets
--------------------------------------------------------------------------------

-- Monster set names, lowercased, longest first. Longest-first matters because
-- one set name can be a prefix of another; the longer match is the right one.
local setNameIndex

local function BuildSetNameIndex()
    if setNameIndex then return setNameIndex end

    setNameIndex = {}
    local setInfo = LibSets and LibSets.setInfo
    if not setInfo then return setNameIndex end

    for setId, data in pairs(setInfo) do
        if data.undauntedChestId ~= nil then
            local name = GetItemSetName(setId)
            if name and name ~= "" then
                setNameIndex[#setNameIndex + 1] = {
                    setId = setId,
                    lower = zo_strlower(zo_strformat(SI_ITEM_SET_NAME_FORMATTER, name)),
                }
            end
        end
    end

    table.sort(setNameIndex, function(a, b) return #a.lower > #b.lower end)
    return setNameIndex
end

-- A curated coffer is named after its set ("<Set> Shoulder Coffer" and the
-- like), so a plain substring test on the game's own set names identifies it
-- without hardcoding item ids, and works in every client language.
local function MatchSet(entryNameLower)
    for _, candidate in ipairs(BuildSetNameIndex()) do
        if string.find(entryNameLower, candidate.lower, 1, true) then
            return candidate.setId
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Working out which quartermaster this is
--------------------------------------------------------------------------------

-- Scoring the scanned sets against each quartermaster's known stock is more
-- dependable than reading the NPC's name: it survives localisation quirks and
-- still lands on the right vendor if the stock has been rotated.
local function IdentifyByStock(setIds)
    local setInfo = LibSets and LibSets.setInfo
    if not setInfo or #setIds == 0 then return nil end

    local scores = {}
    for _, setId in ipairs(setIds) do
        local data = setInfo[setId]
        local vendorId = data and data.undauntedChestId
        if vendorId then
            scores[vendorId] = (scores[vendorId] or 0) + 1
        end
    end

    local best, bestScore = nil, 0
    for vendorId, score in pairs(scores) do
        if score > bestScore then best, bestScore = vendorId, score end
    end
    return best
end

local function IdentifyByName()
    local npcName = zo_strlower(zo_strformat(SI_UNIT_NAME, GetUnitName("interact") or ""))
    if npcName == "" then return nil end

    for _, vendorId in ipairs(MCH.VENDOR_IDS) do
        local vendorName = MCH.Model.GetVendorName(vendorId)
        if vendorName then
            local lower = zo_strlower(vendorName)
            if lower ~= "" and (npcName == lower or string.find(npcName, lower, 1, true)) then
                return vendorId
            end
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Scanning
--------------------------------------------------------------------------------

-- Every store entry that can be bought with Undaunted Keys, with whatever set
-- the name matcher could tie it to.
local function CollectKeyPricedEntries()
    local entries = {}

    for entryIndex = 1, GetNumStoreItems() do
        local _, name, stack, _, _, _, _, _, _, currencyType1, currencyQuantity1,
              currencyType2, currencyQuantity2 = GetStoreEntryInfo(entryIndex)

        -- Undaunted Keys can sit in either currency slot depending on the entry.
        local keyCost
        if currencyType1 == CURT_UNDAUNTED_KEYS then
            keyCost = currencyQuantity1
        elseif currencyType2 == CURT_UNDAUNTED_KEYS then
            keyCost = currencyQuantity2
        end

        if keyCost and keyCost > 0 and stack > 0 then
            local cleanName = zo_strformat(SI_TOOLTIP_ITEM_NAME, name or "")
            entries[#entries + 1] = {
                index = entryIndex,
                name  = cleanName,
                cost  = keyCost,
                setId = MatchSet(zo_strlower(cleanName)),
            }
        end
    end

    return entries
end

-- Most frequent value in a list, ties broken towards the cheaper price.
local function ModalCost(costs)
    local counts = {}
    for _, cost in ipairs(costs) do
        counts[cost] = (counts[cost] or 0) + 1
    end

    local best, bestCount
    for cost, count in pairs(counts) do
        if not best or count > bestCount or (count == bestCount and cost < best) then
            best, bestCount = cost, count
        end
    end
    return best
end

-- A quartermaster stocks one curated coffer per set, all at the same price,
-- against a single cheaper mystery coffer. So the price that repeats across the
-- shelf IS the curated price.
--
-- Deriving it that way rather than from whichever entries the name matcher
-- recognised is deliberate: a coffer whose wording the matcher misses used to
-- drag an unrelated key-priced item into the calculation and blow the price up.
-- Names are still matched, but only to learn which set each coffer is for.
-- Exposed on Store so it can be tested outside the game: it takes plain entry
-- tables and calls no game API.
local MIN_MATCHES_TRUSTED = 3

function Store.DerivePrices(entries)
    if #entries == 0 then return nil, nil, nil end

    local allCosts, matchedCosts = {}, {}
    for _, entry in ipairs(entries) do
        allCosts[#allCosts + 1] = entry.cost
        if entry.setId then matchedCosts[#matchedCosts + 1] = entry.cost end
    end

    -- Trust the matched entries only when enough of them look like a real shelf.
    local curatedCost = (#matchedCosts >= MIN_MATCHES_TRUSTED)
        and ModalCost(matchedCosts)
        or ModalCost(allCosts)

    -- The mystery coffer is the cheap outlier below the curated price, and it is
    -- not named after a set.
    local mysteryEntry
    for _, entry in ipairs(entries) do
        if entry.cost < curatedCost and not entry.setId then
            if not mysteryEntry or entry.cost < mysteryEntry.cost then
                mysteryEntry = entry
            end
        end
    end

    if mysteryEntry then
        return mysteryEntry.cost, curatedCost, mysteryEntry.index
    end
    return nil, curatedCost, nil
end

-- Returns a scan table, or nil when this store is not an Undaunted quartermaster.
function Store.Scan()
    local entries = CollectKeyPricedEntries()
    if #entries == 0 then return nil end

    local mysteryCost, curatedCost, mysteryIndex = Store.DerivePrices(entries)

    -- Only entries selling at the curated price count as coffers. That keeps any
    -- other set-named thing the vendor happens to stock out of both the tooltip
    -- annotations and the learned stock list.
    local curatedIndexToSetId = {}
    local setIds, seenSet = {}, {}

    for _, entry in ipairs(entries) do
        if entry.setId and entry.cost == curatedCost then
            curatedIndexToSetId[entry.index] = entry.setId
            if not seenSet[entry.setId] then
                seenSet[entry.setId] = true
                setIds[#setIds + 1] = entry.setId
            end
        end
    end

    local vendorId = IdentifyByStock(setIds) or IdentifyByName()
    if not vendorId then return nil end

    table.sort(setIds)

    return {
        vendorId            = vendorId,
        setIds              = setIds,
        mysteryIndex        = mysteryIndex,
        mysteryCost         = mysteryCost,
        curatedCost         = curatedCost,
        curatedIndexToSetId = curatedIndexToSetId,
        entries             = entries,
    }
end

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

-- `/coffer scan` while a vendor window is open. Dumps what the game reports so a
-- mismatch between the real shelf and what this addon made of it is visible.
function Store.Dump()
    local count = GetNumStoreItems()
    if count == 0 then
        d("|cDD6666No store is open.|r Talk to an Undaunted quartermaster first.")
        return
    end

    d(string.format("|c9FD3FF[Coffer] store scan: %d entries|r", count))

    for entryIndex = 1, count do
        local _, name, stack, price, _, _, _, _, _, currencyType1, currencyQuantity1,
              currencyType2, currencyQuantity2 = GetStoreEntryInfo(entryIndex)

        local cleanName = zo_strformat(SI_TOOLTIP_ITEM_NAME, name or "")
        local cost = "-"
        if currencyType1 == CURT_UNDAUNTED_KEYS then
            cost = currencyQuantity1 .. " keys"
        elseif currencyType2 == CURT_UNDAUNTED_KEYS then
            cost = currencyQuantity2 .. " keys(2)"
        elseif price and price > 0 then
            cost = price .. " gold"
        end

        local setId = MatchSet(zo_strlower(cleanName))
        local matched = setId
            and ("|c66DD66-> " .. zo_strformat(SI_ITEM_SET_NAME_FORMATTER, GetItemSetName(setId)) .. "|r")
            or "|c9A9A9A-> no set matched|r"

        d(string.format("  %2d. %s  |cFFFFFF[%s]|r  stack %s  %s",
            entryIndex, cleanName, cost, tostring(stack), matched))
    end

    local scan = Store.Scan()
    if not scan then
        d("|cDD6666Not recognised as an Undaunted quartermaster.|r")
        return
    end

    d(string.format("|c9FD3FFDerived:|r vendor %d (%s), mystery %s, curated %s, %d set(s) matched",
        scan.vendorId, MCH.Model.GetVendorName(scan.vendorId),
        tostring(scan.mysteryCost), tostring(scan.curatedCost), #scan.setIds))
end

-- Writes what the scan learned into SavedVariables so the slash command can use
-- real prices and real stock while the player is nowhere near the vendor.
local function Remember(scan)
    local db = MCH.db
    db.learned = db.learned or {}

    local record = db.learned[scan.vendorId] or {}
    record.seenAt = GetTimeStamp()

    -- A shelf where the mystery coffer is not the cheaper option means something
    -- was misread. Keep the previous figures rather than persisting nonsense --
    -- a bad price would otherwise stick around long after leaving the vendor.
    local pricesLookSane = scan.mysteryCost and scan.curatedCost
        and scan.mysteryCost < scan.curatedCost

    if pricesLookSane then
        record.mysteryCost = scan.mysteryCost
        record.curatedCost = scan.curatedCost
    end

    -- Only trust a stock list that actually looks like a quartermaster's shelf.
    -- A partial read would otherwise shrink the pool and skew the odds.
    if #scan.setIds >= 3 then
        record.setIds = scan.setIds
    end

    db.learned[scan.vendorId] = record
    MCH.Model.Invalidate(scan.vendorId)
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnOpenStore()
    local scan = Store.Scan()
    if not scan then return end

    Remember(scan)
    Store.current = scan

    local result = MCH.Advisor.ForVendor(scan.vendorId)
    if not result then return end

    if MCH.db.chatMessage then
        MCH.Format.PrintToChat(result)
    end
    if MCH.db.showPanel then
        MCH.UI.Show(result, scan.vendorId)
    end
end

local function OnCloseStore()
    Store.current = nil
    MCH.UI.HideIfAuto()
end

function Store.Initialize()
    EVENT_MANAGER:RegisterForEvent(MCH.name, EVENT_OPEN_STORE, OnOpenStore)
    EVENT_MANAGER:RegisterForEvent(MCH.name, EVENT_CLOSE_STORE, OnCloseStore)
end
