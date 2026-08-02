-- AccountHold/src/Priorities.lua
-- Epic 0005 -- the player-curated wishlist ("I want this") cross-referenced
-- against what the account already owns and rolled up into a de-duplicated
-- activity plan: "what should I go do tonight?".
--
-- Model layer only. The Priorities screen is a separate module, blocked behind
-- the S1 menu-placement spike (open question O2), and nothing here draws,
-- registers an event, or touches the base UI.
--
-- Reads AccountHold.Index for ownership (never writes to it) and delegates the
-- activity rollup to AccountHold.SetSources, which epic 0002 shares. Both are
-- optional at runtime: a missing module degrades to an empty plan rather than
-- an error, per contract C.

AccountHold = AccountHold or {}
AccountHold.Priorities = AccountHold.Priorities or {}

local Priorities = AccountHold.Priorities
local addon

local KIND_SET  = "set"
local KIND_ITEM = "item"

Priorities.KIND_SET  = KIND_SET
Priorities.KIND_ITEM = KIND_ITEM

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

function Priorities:Initialize(addonRef)
    addon = addonRef
end

-- ---------------------------------------------------------------------------
-- SavedVariables access
-- ---------------------------------------------------------------------------

-- sv.priorities may legitimately be nil: the coordinator owns DEFAULTS and the
-- dataVersion migration that seeds it, and this module has to load on an
-- install that predates both. Reads degrade to an empty list WITHOUT creating
-- the key -- a read must never dirty SavedVariables -- and writes create it.
local EMPTY = {}

local function sv()
    return addon and addon.sv or nil
end

local function readList()
    local s = sv()
    local list = s and s.priorities
    if type(list) ~= "table" then return EMPTY end
    return list
end

local function writeList()
    local s = sv()
    if not s then return nil end
    if type(s.priorities) ~= "table" then s.priorities = {} end
    return s.priorities
end

-- Ids come from sv.nextPriorityId when the coordinator's DEFAULTS have seeded
-- it, but are ALSO derived from the records present, so a pre-migration install
-- or a hand-edited SavedVariables file can never mint a duplicate id (which
-- would make Remove delete the wrong row). Contract B assigns this epic
-- sv.priorities only, so no new SavedVariables key is invented here.
local function nextId(list)
    local s = sv()
    local n = tonumber(s and s.nextPriorityId) or 1
    for i = 1, #list do
        local id = tonumber(list[i].id)
        if id and id >= n then n = id + 1 end
    end
    if s then s.nextPriorityId = n + 1 end
    return n
end

local function timestamp()
    if type(GetTimeStamp) == "function" then
        local ok, ts = pcall(GetTimeStamp)
        if ok and type(ts) == "number" then return ts end
    end
    return 0
end

-- ---------------------------------------------------------------------------
-- Spec normalization
-- ---------------------------------------------------------------------------

-- spec = { kind = "set", setId = n } | { kind = "item", itemSignature = s }
--
-- Console note: an item priority is always added by SELECTING an existing
-- Quartermaster row and handing over its itemSignature, never by typing --
-- Platform.SupportsFreeTextSearch() is false on console, so there is no
-- free-text path into this function by design.
local function normalizeSpec(spec)
    if type(spec) ~= "table" then return nil end
    if spec.kind == KIND_SET then
        local setId = tonumber(spec.setId)
        if not setId or setId <= 0 then return nil end
        return { kind = KIND_SET, setId = setId }
    elseif spec.kind == KIND_ITEM then
        local sig = spec.itemSignature
        if type(sig) ~= "string" or sig == "" then return nil end
        return { kind = KIND_ITEM, itemSignature = sig }
    end
    return nil
end

-- Identity for de-duplication. An item record caches a resolved setId (see
-- Add), so identity must compare ONLY the field that defines the priority --
-- comparing setId here would let the same item be added twice.
local function findRecord(list, norm)
    for i = 1, #list do
        local rec = list[i]
        if rec.kind == norm.kind then
            if norm.kind == KIND_SET and tonumber(rec.setId) == norm.setId then
                return rec
            elseif norm.kind == KIND_ITEM and rec.itemSignature == norm.itemSignature then
                return rec
            end
        end
    end
    return nil
end

-- GetItemLinkSetInfo returns SEVEN values and setId is the SIXTH (doc :18980:
-- hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId,
-- numPerfectedEquipped). Capturing fewer yields nil for the one value we want,
-- which is the same class of bug as the nine-value node info reader in
-- src/Travel.lua -- so the whole tuple is named here too.
local function setIdForSignature(sig)
    if type(sig) ~= "string" or sig == "" then return nil end
    if type(GetItemLinkSetInfo) ~= "function" then return nil end
    local ok, hasSet, setName, numBonuses, numNormalEquipped, maxEquipped,
          setId, numPerfectedEquipped = pcall(GetItemLinkSetInfo, sig, false)
    local _ = setName, numBonuses, numNormalEquipped, maxEquipped, numPerfectedEquipped
    if not ok or not hasSet then return nil end
    setId = tonumber(setId)
    if not setId or setId <= 0 then return nil end
    return setId
end

-- ---------------------------------------------------------------------------
-- Wishlist CRUD (contract C)
-- ---------------------------------------------------------------------------

function Priorities:Add(spec)
    local norm = normalizeSpec(spec)
    if not norm then return nil end

    local existing = findRecord(readList(), norm)
    if existing then return existing end

    local list = writeList()
    if not list then return nil end

    local rec = {
        id            = nextId(list),
        kind          = norm.kind,
        setId         = norm.setId,
        itemSignature = norm.itemSignature,
        addedAt       = timestamp(),
    }

    if rec.kind == KIND_ITEM then
        -- Resolve and CACHE the piece's set now, while the item link is in
        -- hand. BuildPlan needs the set to place this item on an activity, and
        -- by then the item is by definition NOT in the account index (that is
        -- exactly what makes it outstanding), so it could not be recovered from
        -- Index later. The record shape in contract C already allows setId on
        -- any record, so this needs no schema change.
        rec.setId = setIdForSignature(rec.itemSignature)
    end

    list[#list + 1] = rec
    return rec
end

function Priorities:Remove(id)
    id = tonumber(id)
    if not id then return false end
    local s = sv()
    local list = s and s.priorities
    if type(list) ~= "table" then return false end
    for i = 1, #list do
        if tonumber(list[i].id) == id then
            table.remove(list, i)
            return true
        end
    end
    return false
end

-- Fresh array so a caller cannot reorder SavedVariables by sorting the result;
-- the records themselves are live, which is what the row actions need. Order is
-- insertion order (Add appends, Remove uses table.remove), so newest is last.
function Priorities:List()
    local list = readList()
    local out = {}
    for i = 1, #list do out[i] = list[i] end
    return out
end

function Priorities:IsPrioritized(spec)
    local norm = normalizeSpec(spec)
    if not norm then return false end
    return findRecord(readList(), norm) ~= nil
end

-- ---------------------------------------------------------------------------
-- Ownership -> outstanding
-- ---------------------------------------------------------------------------
--
-- WHY THE STICKER BOOK IS THE PRIMARY SOURCE AND THE INDEX IS THE FALLBACK
--
-- "Outstanding" has to mean "pieces I would still have to go and get". Two
-- sources can answer that, and they disagree in both directions:
--
--   * The Item Set Collection ("sticker book"):
--     GetNumItemSetCollectionSlotsUnlocked(setId) (doc :17909) over
--     GetNumItemSetCollectionPieces(setId) (doc :17903). This is exactly the
--     N/M the in-game Collections screen shows, and it is PERMANENT: an
--     unlocked slot can be reconstructed forever, so a piece recorded there
--     never has to be farmed again even after the player sells, deconstructs or
--     loses it. That is literally 0005's "I never farm something twice" story,
--     which makes it the semantically correct notion of "owned" here -- not
--     merely the convenient one.
--
--   * AccountHold's own Index: distinct pieces of the set physically present
--     across the account. It can see UNBOUND pieces sitting in a bank or guild
--     bank that the sticker book has no record of. But Index:GetKnownSets
--     counts distinct pieces by ITEM NAME, so the light/medium/heavy variants
--     of one armour slot count as three. For an overland set that can exceed
--     the collection's piece count and drive outstanding to 0 -- silently
--     deleting a set the player still wants from their plan.
--
-- Merging the two (max, or sum) inherits that over-count hazard, so the sticker
-- book wins outright wherever it is available and the Index is used only as a
-- degraded fallback, clamped to the known total. Every read is type-guarded and
-- pcall-wrapped: on a client without the collection API, or in the test
-- harness, this falls through to the Index and then to the honest floor in
-- outstandingForSet.

-- With no piece count for a set we cannot compute a difference, and "unknown"
-- is emphatically not "done". One is the smallest honest non-zero weight: the
-- set keeps its place on the plan, only the ordering precision is lost.
local UNKNOWN_TOTAL_OUTSTANDING = 1

local function stickerBookTotal(setId)
    if type(GetNumItemSetCollectionPieces) ~= "function" then return nil end
    local ok, n = pcall(GetNumItemSetCollectionPieces, setId)
    if ok and type(n) == "number" and n > 0 then return n end
    return nil
end

local function stickerBookUnlocked(setId)
    if type(GetNumItemSetCollectionSlotsUnlocked) ~= "function" then return nil end
    local ok, n = pcall(GetNumItemSetCollectionSlotsUnlocked, setId)
    if ok and type(n) == "number" and n >= 0 then return n end
    return nil
end

-- One pass over Index:GetKnownSets for the whole plan. That call rebuilds the
-- row cache and walks every stored item, so calling it once per wanted set
-- would make BuildPlan quadratic in the size of the account snapshot.
-- Returns nil (not an empty map) when Index is unavailable, because "no Index"
-- and "Index says you own none" must not collapse into the same answer.
local function ownedPiecesByIndex()
    local Index = AccountHold and AccountHold.Index
    if not Index or type(Index.GetKnownSets) ~= "function" then return nil end
    local ok, sets = pcall(Index.GetKnownSets, Index)
    if not ok or type(sets) ~= "table" then return nil end
    local map = {}
    for i = 1, #sets do
        local rec = sets[i]
        local id = tonumber(rec and rec.setId)
        if id then map[id] = tonumber(rec.count) or 0 end
    end
    return map
end

local function outstandingForSet(setId, indexOwned)
    local total = stickerBookTotal(setId)
    if not total then
        -- Either the client predates the Item Set Collection API, or this set
        -- is not in the collection at all -- crafted sets have a station rather
        -- than a drop table (open question O4), and they report no pieces.
        return UNKNOWN_TOTAL_OUTSTANDING
    end

    local owned = stickerBookUnlocked(setId)
    if not owned then
        local fromIndex = indexOwned and indexOwned[setId]
        if type(fromIndex) == "number" then owned = fromIndex else owned = 0 end
    end

    if owned < 0 then owned = 0 end
    -- Clamp: the Index fallback counts by item name, so armour-weight variants
    -- can push it past the real piece count.
    if owned > total then owned = total end
    return total - owned
end

-- An item priority is outstanding iff the account index holds no matching row.
-- Index:RowsForHold already implements exactly this rule (itemSignature
-- equality) for the Mover, so it is reused rather than reimplemented.
-- With no Index we cannot prove ownership, and claiming a piece is owned would
-- silently remove work from the plan, so the safe default is "outstanding".
local function itemIsOutstanding(sig)
    local Index = AccountHold and AccountHold.Index
    if not Index or type(Index.RowsForHold) ~= "function" then return true end
    local ok, rows = pcall(Index.RowsForHold, Index,
        { holdType = KIND_ITEM, itemSignature = sig })
    if not ok or type(rows) ~= "table" then return true end
    return #rows == 0
end

-- ---------------------------------------------------------------------------
-- The plan
-- ---------------------------------------------------------------------------

-- Cross-references Index for ownership and rolls the result up through
-- SetSources into de-duplicated activities, ordered by outstanding pieces
-- descending (RollupActivities owns the sort). Activities with nothing
-- outstanding are omitted.
function Priorities:BuildPlan()
    local list = readList()
    if #list == 0 then return {} end

    local SetSources = AccountHold and AccountHold.SetSources
    if not SetSources or type(SetSources.RollupActivities) ~= "function" then
        -- Contract C: never throw when SetSources is absent. Without the source
        -- database there is no activity to name, so the plan is empty; the
        -- wishlist itself is still readable through :List().
        if addon and addon.Debug then
            addon:Debug("Priorities:BuildPlan - SetSources unavailable, empty plan.")
        end
        return {}
    end

    local indexOwned = ownedPiecesByIndex()

    local outstanding = {}   -- setId -> outstanding count
    local setWanted   = {}   -- setId -> true, only for KIND_SET records
    local order       = {}   -- deterministic setId order for the rollup input

    local function ensure(setId)
        if outstanding[setId] == nil then
            outstanding[setId] = 0
            order[#order + 1] = setId
        end
    end

    -- Pass 1 -- set priorities.
    for i = 1, #list do
        local rec = list[i]
        if rec.kind == KIND_SET then
            local setId = tonumber(rec.setId)
            if setId and not setWanted[setId] then
                setWanted[setId] = true
                ensure(setId)
                outstanding[setId] = outstandingForSet(setId, indexOwned)
            end
        end
    end

    -- Pass 2 -- item priorities. OPEN QUESTION O5, decided here.
    --
    -- An item priority DOES roll up to its set's activity. 0005 asks "what
    -- should I go do tonight?", and an item row that maps to no activity
    -- answers nothing at all -- exact-match-only would make item priorities
    -- inert in the one screen they exist to feed. It contributes exactly ONE
    -- outstanding piece, and only when the account does not already hold it.
    --
    -- It contributes NOTHING when that set is already on the wishlist as a set
    -- priority: the set's own outstanding count already covers this piece, and
    -- adding to it would inflate the ordering and push the activity above ones
    -- that genuinely need more work. The list is a plan, not a receipt.
    for i = 1, #list do
        local rec = list[i]
        if rec.kind == KIND_ITEM and type(rec.itemSignature) == "string" then
            local setId = tonumber(rec.setId) or setIdForSignature(rec.itemSignature)
            if not setId then
                -- No resolvable set means no activity can be named for it. The
                -- row stays in :List() so the player still sees what they asked
                -- for; it simply cannot appear in the plan. Rolling it up under
                -- the synthetic "unknown" activity is SetSources' job and needs
                -- a setId to key on, which is precisely what we lack.
                if addon and addon.Debug then
                    addon:Debug("Priorities: item priority %s has no resolvable set; not planned.",
                        tostring(rec.id))
                end
            elseif not setWanted[setId] and itemIsOutstanding(rec.itemSignature) then
                ensure(setId)
                outstanding[setId] = outstanding[setId] + 1
            end
        end
    end

    -- Only sets with work left are handed to the rollup. Passing a fully-owned
    -- set through with outstanding = 0 would still list it in the activity's
    -- setIds, so the row would claim to cover a set the player has already
    -- finished.
    local wanted = {}
    for i = 1, #order do
        local setId = order[i]
        local n = outstanding[setId]
        if n and n > 0 then
            wanted[#wanted + 1] = { setId = setId, outstanding = n }
        end
    end
    if #wanted == 0 then return {} end

    local ok, activities = pcall(SetSources.RollupActivities, SetSources, wanted)
    if not ok or type(activities) ~= "table" then
        if addon and addon.Diagnostic then
            addon:Diagnostic("error", "Priorities:BuildPlan - rollup failed: %s",
                tostring(activities))
        end
        return {}
    end

    -- Belt and braces: the input already excludes zero-outstanding sets, but
    -- 0005's acceptance criteria are explicit that an activity with nothing
    -- outstanding must not be shown, and this module owns that guarantee
    -- regardless of what the shared rollup returns.
    local plan = {}
    for i = 1, #activities do
        local activity = activities[i]
        if type(activity) == "table" and (tonumber(activity.outstanding) or 0) > 0 then
            plan[#plan + 1] = activity
        end
    end
    return plan
end
