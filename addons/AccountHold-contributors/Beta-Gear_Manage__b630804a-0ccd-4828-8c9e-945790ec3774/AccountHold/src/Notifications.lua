-- AccountHold/src/Notifications.lua
--
-- Epic 0008 (QoL) -- MODEL LAYER for "clear every new-item notification".
--
-- The Item Sets book already has a per-book clear action
-- (ui/PrioritiesSetsBook_Gamepad.lua). This module generalises that to every
-- surface that carries a "new" marker, so a single action can clear the lot.
-- It owns NO UI: it counts and it clears, and a caller decides where that is
-- surfaced. That split is deliberate -- the same model backs the Collections
-- keybind today and can back a settings action or a slash command later
-- without being rewritten.
--
-- VERIFIED API CONTRACT (esoui/esoui @ master; ESOUIDocumentation.txt).
-- Every entry below was read from upstream source. Names that do NOT exist are
-- recorded too, because they are plausible-sounding and were proposed during
-- design -- writing them down stops them being reintroduced:
--
--   EXISTS
--     SHARED_INVENTORY:IsItemNew(bagId, slotIndex)        sharedinventory.lua:620-625
--     SHARED_INVENTORY:ClearNewStatus(bagId, slotIndex)   sharedinventory.lua:618-625
--     GetBagSize(bagId)                                   ESOUIDocumentation.txt
--     GetNumNewCollectibles()                             ESOUIDocumentation.txt
--     GetNumCollectibleCategories()                       ESOUIDocumentation.txt
--     ClearCollectibleCategoryNewStatuses(catIndex, subIndex:nilable)
--                                                         ESOUIDocumentation.txt
--     ClearCollectibleNewStatus(collectibleId)            ESOUIDocumentation.txt
--   None of the above carries a *protected* or *private* marker, so all are
--   callable from any context -- we do NOT need a hardware-input frame.
--
--   DOES NOT EXIST -- do not reintroduce
--     SHARED_INVENTORY:ClearNewStatusOnAllItemsInBag(bagId)
--     ZO_ClearAllNewStatus()
--   Both were proposed from recollection and are absent from the entire esoui
--   tree. There is NO bulk "clear this whole bag" call: bags are walked slot by
--   slot. ZO_InventoryManager:ClearNewStatusOnItemsThePlayerHasSeen exists
--   (inventory.lua) but hangs off a PRIVATE manager object with no addon-
--   reachable global, and only clears rows the player already scrolled past.
--
-- HONESTY NOTE -- THE TWO SURFACES DO NOT BEHAVE THE SAME
-- ------------------------------------------------------
-- SHARED_INVENTORY:ClearNewStatus is a LUA CACHE write. It sets slotData.age = 0
-- and slotData.brandNew = nil on the in-session cache and calls
-- RefreshStatusSortOrder. There is no C call behind it, so inventory and craft
-- bag markers RETURN after a reloadui or a relog. Collectible clears go through
-- the C API and persist. Callers must not promise the player more than that;
-- Summary() reports the two classes separately so the UI can word it honestly.
--
-- ESO runs Lua 5.1: no goto, no bitwise operators, no integer division. This
-- file must LOAD under tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.Notifications = AccountHold.Notifications or {}

local N = AccountHold.Notifications

-- Foundation layer (src/core/Safe.lua), loaded ahead of this file by the
-- manifest. Resolved at call time rather than captured at load time so this
-- module still degrades to a safe no-op if the layer is ever absent -- and so
-- tests can load this file standalone.
local function safe()
    local core = AccountHold and AccountHold.Core
    local S = core and core.Safe
    if type(S) == "table" then return S end
    return nil
end

-- Hard ceiling on any single bag walk. GetBagSize should bound this already;
-- the cap exists so a hostile or broken GetBagSize cannot hang the client. A
-- hung console session needs a full hard restart, so every loop in this add-on
-- is bounded on principle.
local MAX_BAG_SLOTS   = 10000
-- Same reasoning for the collectible category walk.
local MAX_CATEGORIES  = 1000

N.MAX_BAG_SLOTS  = MAX_BAG_SLOTS
N.MAX_CATEGORIES = MAX_CATEGORIES

-- ---------------------------------------------------------------------------
-- Safe access to engine singletons
--
-- SHARED_INVENTORY is an ENGINE-BACKED object. It must NEVER be gated on
-- type(x) == "table": ESO engine globals are userdata (globalvars.lua:2-4), so
-- a table test is FALSE on real hardware and the whole feature silently no-ops
-- while passing every mock test. That exact bug class already shipped in this
-- add-on once. Guard on the METHOD, never on the type -- which is precisely
-- what Safe.Method does, so this module delegates rather than re-deriving it.
-- ---------------------------------------------------------------------------
local function method(obj, name)
    local S = safe()
    if S ~= nil then return S.Method(obj, name) end
    -- Standalone fallback with identical semantics.
    if obj == nil then return nil end
    local ok, fn = pcall(function() return obj[name] end)
    if ok and type(fn) == "function" then return fn end
    return nil
end

local function call(fn, ...)
    local S = safe()
    if S ~= nil then return S.Call(fn, ...) end
    if type(fn) ~= "function" then return false, nil end
    local ok, res = pcall(fn, ...)
    if not ok then return false, nil end
    return true, res
end

N._Method = method

-- ---------------------------------------------------------------------------
-- Bag surfaces (inventory, craft bag, bank)
-- ---------------------------------------------------------------------------

-- Walk one bag and hand every NEW slot index to `visit`. Returns the count of
-- new slots seen. `visit` may be nil to count only.
function N.ForEachNewInBag(bagId, visit)
    if bagId == nil then return 0 end
    if type(GetBagSize) ~= "function" then return 0 end

    local isNew = method(SHARED_INVENTORY, "IsItemNew")
    if isNew == nil then return 0 end

    local okSize, size = call(GetBagSize, bagId)
    if not okSize or type(size) ~= "number" or size <= 0 then return 0 end
    if size > MAX_BAG_SLOTS then size = MAX_BAG_SLOTS end

    -- Slot indices are 0-based (GetBagSize returns the count, and the base game
    -- iterates 0..size-1 -- see ZO_SharedInventoryManager:RefreshInventory).
    local count = 0
    for slotIndex = 0, size - 1 do
        local okNew, res = call(isNew, SHARED_INVENTORY, bagId, slotIndex)
        if okNew and res then
            count = count + 1
            if type(visit) == "function" then
                call(visit, bagId, slotIndex)
            end
        end
    end
    return count
end

function N.CountNewInBag(bagId)
    return N.ForEachNewInBag(bagId, nil)
end

-- Clear every new marker in one bag. Returns the number cleared.
--
-- Collect first, then clear: ClearNewStatus mutates the same cache IsItemNew
-- reads, and RefreshStatusSortOrder may reorder it underneath a live walk.
function N.ClearNewInBag(bagId)
    local clear = method(SHARED_INVENTORY, "ClearNewStatus")
    if clear == nil then return 0 end

    local pending = {}
    N.ForEachNewInBag(bagId, function(bag, slotIndex)
        pending[#pending + 1] = slotIndex
    end)

    local cleared = 0
    for i = 1, #pending do
        if call(clear, SHARED_INVENTORY, bagId, pending[i]) then
            cleared = cleared + 1
        end
    end
    return cleared
end

-- The bags we sweep, in a deterministic order. BAG_VIRTUAL is the craft bag
-- (inventory.lua maps [BAG_VIRTUAL] = INVENTORY_CRAFT_BAG). Absent globals are
-- skipped rather than defaulted: a wrong numeric bag id would walk the wrong
-- container.
function N.Bags()
    local out = {}
    local function add(id, key)
        if type(id) == "number" then out[#out + 1] = { id = id, key = key } end
    end
    add(BAG_BACKPACK, "inventory")
    add(BAG_VIRTUAL,  "craftBag")
    add(BAG_BANK,     "bank")
    return out
end

-- ---------------------------------------------------------------------------
-- Collectibles
--
-- Unlike bags there IS a bulk call here: ClearCollectibleCategoryNewStatuses
-- takes a top-level category index and a NILABLE subcategory index, and
-- clearing with a nil subcategory covers every subcategory beneath it. So the
-- whole surface is N calls where N is the number of top-level categories,
-- rather than one call per collectible.
-- ---------------------------------------------------------------------------

function N.CountNewCollectibles()
    if type(GetNumNewCollectibles) ~= "function" then return 0 end
    local ok, n = pcall(GetNumNewCollectibles)
    if ok and type(n) == "number" and n > 0 then return n end
    return 0
end

-- Returns the number that WERE new before the sweep (the API reports no count).
function N.ClearNewCollectibles()
    if type(ClearCollectibleCategoryNewStatuses) ~= "function" then return 0 end
    if type(GetNumCollectibleCategories) ~= "function" then return 0 end

    local before = N.CountNewCollectibles()
    if before <= 0 then return 0 end

    local okNum, numCats = pcall(GetNumCollectibleCategories)
    if not okNum or type(numCats) ~= "number" or numCats <= 0 then return 0 end
    if numCats > MAX_CATEGORIES then numCats = MAX_CATEGORIES end

    for i = 1, numCats do
        -- nil subcategory == every subcategory under this top-level category.
        pcall(ClearCollectibleCategoryNewStatuses, i, nil)
    end

    -- Report what actually went away, not what we hoped would.
    local after = N.CountNewCollectibles()
    local cleared = before - after
    if cleared < 0 then cleared = 0 end
    return cleared
end

-- ---------------------------------------------------------------------------
-- Item sets
--
-- Delegated to the Item Sets book module, which already implements a bounded
-- walk with the sendUpdate-on-last-only optimisation. Looked up at CALL time,
-- never at load time: src/ loads before ui/ in the manifest, so a load-time
-- reference would always be nil. Same late-binding trick as
-- Platform.GetSettingsBackend.
-- ---------------------------------------------------------------------------

local function setsBook()
    local ui = AccountHold and AccountHold.UI
    local book = ui and ui.PrioritiesSetsBookGamepad
    if type(book) == "table" then return book end
    return nil
end

function N.CountNewItemSetPieces()
    local book = setsBook()
    if book == nil or type(book.CountNewPieces) ~= "function" then return 0 end
    local ok, n = pcall(book.CountNewPieces)
    if ok and type(n) == "number" and n > 0 then return n end
    return 0
end

function N.ClearNewItemSetPieces()
    local book = setsBook()
    if book == nil or type(book.ClearAllNewPieces) ~= "function" then return 0 end
    local ok, n = pcall(book.ClearAllNewPieces)
    if ok and type(n) == "number" and n > 0 then return n end
    return 0
end

-- ---------------------------------------------------------------------------
-- Aggregate
-- ---------------------------------------------------------------------------

-- Summary() -> {
--   total       = <number>,   -- everything, for the button label
--   persistent  = <number>,   -- survives a reload once cleared (collectibles, sets)
--   sessionOnly = <number>,   -- bag markers; they come back on reload
--   byKey       = { inventory = n, craftBag = n, bank = n, collectibles = n, itemSets = n },
-- }
--
-- Split by persistence so the UI can tell the truth about what a clear buys.
function N.Summary()
    local byKey = {}
    local sessionOnly = 0

    local bags = N.Bags()
    for i = 1, #bags do
        local n = N.CountNewInBag(bags[i].id)
        byKey[bags[i].key] = n
        sessionOnly = sessionOnly + n
    end

    local collectibles = N.CountNewCollectibles()
    local itemSets     = N.CountNewItemSetPieces()
    byKey.collectibles = collectibles
    byKey.itemSets     = itemSets

    local persistent = collectibles + itemSets
    return {
        total       = sessionOnly + persistent,
        persistent  = persistent,
        sessionOnly = sessionOnly,
        byKey       = byKey,
    }
end

function N.CountAll()
    local s = N.Summary()
    return s.total
end

-- ClearAll() -> cleared, byKey
--
-- Every surface is swept even if an earlier one fails: one broken API must not
-- deny the player the rest of the action.
function N.ClearAll()
    local byKey, cleared = {}, 0

    local bags = N.Bags()
    for i = 1, #bags do
        local n = N.ClearNewInBag(bags[i].id)
        byKey[bags[i].key] = n
        cleared = cleared + n
    end

    local c = N.ClearNewCollectibles()
    byKey.collectibles = c
    cleared = cleared + c

    local s = N.ClearNewItemSetPieces()
    byKey.itemSets = s
    cleared = cleared + s

    return cleared, byKey
end

return N
