-- AccountHold/src/Travel.lua
-- Guarded wrapper over ESO's wayshrine APIs (epic 0005, contract D).
--
-- === ToS-CRITICAL MODULE =====================================================
-- The travel API carries NO `*protected*` marker in ESOUIDocumentation.txt
-- (:13872), unlike e.g. `PlaceInTradeWindow *protected*` (:11385). The client
-- will therefore happily teleport the player from a timer, an event handler or
-- a list refresh. 0005's privacy/ToS section draws the line exactly there:
-- ability to automate is not permission to automate.
--
-- This module exists so "travel only ever happens because the player just
-- confirmed it" is a property of ONE function in ONE file rather than a
-- convention scattered across the UI. The structural rules below are all
-- assertable from the test harness:
--
--   1. Travel:TravelTo holds the ONLY call site of the travel API in the whole
--      add-on. A source scan for the call pattern must find exactly one hit,
--      in this file.
--   2. This module registers NOTHING. No EVENT_MANAGER event, no
--      RegisterForUpdate timer, no scene fragment, no callback. There is
--      consequently no edge from any game event to TravelTo inside the add-on;
--      Initialize only stores the addon reference.
--   3. No other function here reaches TravelTo. FindNodeForActivity,
--      CanTravelTo, GetCost and GetReasonText are pure reads and are safe to
--      call from a render/refresh path.
--   4. TravelTo re-runs CanTravelTo itself and never trusts its caller, so a
--      mis-wired UI cannot jump to a node the player may not reach.
--   5. Two jumps inside one frame cannot both be user confirmations, so the
--      second is refused. That is what makes chaining/queueing impossible
--      rather than merely discouraged.
--
-- The intended caller is a dialog confirm callback, mirroring the base game:
-- ESO_Dialogs["FAST_TRAVEL_CONFIRM"] in esoui/ingame/globals/ingamedialogs.lua
-- records `confirmedFastTravel` in its confirm button and performs the jump
-- only from `finishedCallback`, deferring until the dialog hides (its own
-- comment, ESO-796774).
-- =============================================================================

AccountHold = AccountHold or {}
AccountHold.Travel = AccountHold.Travel or {}

local Travel = AccountHold.Travel
local addon

-- Strings are registered centrally by the coordinator; feature agents must not
-- edit localization/en.lua (concurrent edits to one shared file collide). This
-- resolves through AccountHold.L when it exists and renders the English literal
-- otherwise, so the module is correct either way.
local function L(id, fallback)
    if AccountHold and type(AccountHold.L) == "function" then
        return AccountHold.L(id, fallback)
    end
    return fallback
end

-- Machine reason keys, frozen by contract D. Exported so callers and tests
-- compare against a constant rather than a re-typed literal.
local REASON_OK              = "ok"
local REASON_UNKNOWN_NODE    = "unknown_node"
local REASON_NOT_DISCOVERED  = "not_discovered"
local REASON_CANNOT_TELEPORT = "cannot_teleport"
local REASON_NO_API          = "no_api"

Travel.REASON_OK              = REASON_OK
Travel.REASON_UNKNOWN_NODE    = REASON_UNKNOWN_NODE
Travel.REASON_NOT_DISCOVERED  = REASON_NOT_DISCOVERED
Travel.REASON_CANNOT_TELEPORT = REASON_CANNOT_TELEPORT
Travel.REASON_NO_API          = REASON_NO_API

-- How a node was matched to an activity. "zone" means we only found the
-- containing zone's wayshrine, which lands the player nearby rather than at the
-- door (open question O3) -- the UI must say so before charging them for it.
Travel.MATCH_ACTIVITY = "activity"
Travel.MATCH_ZONE     = "zone"

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

-- Deliberately inert. Registering an event or an update timer here would create
-- exactly the automation path rule 2 above forbids, so this stores the addon
-- reference (for diagnostics) and nothing else.
function Travel:Initialize(addonRef)
    addon = addonRef
end

-- ---------------------------------------------------------------------------
-- Guarded API readers
-- ---------------------------------------------------------------------------

local function nodeCount()
    if type(GetNumFastTravelNodes) ~= "function" then return nil end
    local ok, n = pcall(GetNumFastTravelNodes)
    if ok and type(n) == "number" and n >= 0 then return n end
    return nil
end

-- GetFastTravelNodeInfo returns NINE values (doc :13851, returns on :13852):
--   known, name, normalizedX, normalizedY, icon, glowIcon, poiType,
--   isShownInCurrentMap, linkedCollectibleIsLocked
--
-- Reading it as `local ok, value = pcall(...)` keeps `known` and throws away
-- the other eight -- the precise mistake that cost this add-on a whole filter
-- category. Every read goes through this one function, which takes the full
-- tuple and hands back a named record so no caller can repeat it.
local function nodeInfo(nodeIndex)
    if type(GetFastTravelNodeInfo) ~= "function" then return nil end
    local ok, known, name, normalizedX, normalizedY, icon, glowIcon,
          poiType, isShownInCurrentMap, linkedCollectibleIsLocked =
        pcall(GetFastTravelNodeInfo, nodeIndex)
    if not ok then return nil end
    return {
        known                     = known and true or false,
        name                      = (type(name) == "string") and name or "",
        normalizedX               = tonumber(normalizedX),
        normalizedY               = tonumber(normalizedY),
        icon                      = icon,
        glowIcon                  = glowIcon,
        poiType                   = poiType,
        -- isShownInCurrentMap is a MAP RENDERING flag (does this pin draw on
        -- the map currently on screen). worldmap.lua reads it when building
        -- pins, never when deciding whether a jump is legal, so gating travel
        -- on it would block every node outside the open map. Captured for
        -- completeness, deliberately not used as a gate.
        isShownInCurrentMap       = isShownInCurrentMap and true or false,
        linkedCollectibleIsLocked = linkedCollectibleIsLocked and true or false,
    }
end

-- ---------------------------------------------------------------------------
-- Node lookup by name
-- ---------------------------------------------------------------------------

-- Node names are static for a session (only `known` flips as the player
-- discovers shrines, and that is read live in CanTravelTo), so the name map is
-- built once. Rebuilt whenever the node count changes, which is the only cheap
-- signal that the node table itself moved (e.g. a house node was added).
local nameIndex      = nil
local nameIndexCount = nil

-- ESO ships gender/plural markup on location strings ("Vivec City^N") and the
-- bundled source DB is written in plain English, so both sides are folded to a
-- comparable form. Kept deliberately minimal: every extra normalisation step is
-- another way for two different places to collide into one match.
local function normalizeName(name)
    if type(name) ~= "string" then return nil end
    local s = name:gsub("%^%a+", "")
    s = s:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:lower()
    s = s:gsub("%s+", " ")
    s = s:gsub("^ +", ""):gsub(" +$", "")
    if s == "" then return nil end
    return s
end

-- A second, PUNCTUATION-BLIND key.
--
-- The activity name and the map node name come from two different places --
-- the Item Set Collection category tree and the fast-travel node list -- and
-- they disagree on punctuation and spacing far more often than on words.
-- "Selene's Web" / "Selenes Web" and "Crypt of Hearts I" / "Crypt of Hearts
-- I." both have to resolve, or the row reports "No wayshrine known" for a
-- dungeon the player can plainly see on their map.
local function looseName(name)
    if type(name) ~= "string" then return nil end
    local s = normalizeName(name)
    if not s then return nil end
    s = s:gsub("[^%w]", "")
    if s == "" then return nil end
    return s
end

Travel._NormalizeName = normalizeName
Travel._LooseName     = looseName

-- ---------------------------------------------------------------------------
-- CANONICAL name (BUGS.md QMQ-1) -- built from OBSERVED hardware data.
--
-- The Quartermaster Queue could not resolve a single group dungeon, and the
-- reason was invisible from source because it is game data. Traced on Xbox:
--
--     activity name : "Fungal Grotto I"
--     node name     : "Dungeon: Fungal Grotto I"      (poi=GROUP_DUNGEON, zone 41)
--
-- THE WHOLE MISMATCH IS THE CATEGORY PREFIX. The node carries a leading
-- "Dungeon: " that the activity name does not. Both sides use the same roman
-- numeral. That single prefix defeated every existing tier: exact matching
-- compared "dungeon: fungal grotto i" against "fungal grotto i", and the
-- punctuation-blind tier compared "dungeonfungalgrotton1"-style keys, which
-- share no equality either. Stripping the prefix is the fix.
--
-- The trailing roman -> arabic fold is DEFENSIVE, not required by the observed
-- data. "I" and "1" are visually near-identical in the client font, ESO is not
-- consistent about numbering across content, and the fold is applied to BOTH
-- sides symmetrically -- so it cannot introduce a mismatch, and it makes the
-- matcher agnostic to which form either side uses.
--
--     "Dungeon: Fungal Grotto I" -> "fungalgrotto1"
--     "Fungal Grotto I"          -> "fungalgrotto1"
--     "Fungal Grotto 1"          -> "fungalgrotto1"
--
-- This is a NARROW transformation, deliberately. It strips one leading
-- "<words>: " prefix and converts one TRAILING roman numeral. It does not do
-- substring matching, stemming, or edit distance -- the surrounding code's rule
-- still stands: "a wrong match teleports the player across the map and charges
-- them gold for it, so silence beats a guess."
-- ---------------------------------------------------------------------------

-- Roman numerals as they appear in ESO dungeon names. ESO ships I and II
-- widely, III rarely; the rest are here so the table is not a trap for a
-- future dungeon.
local ROMAN_TO_ARABIC = {
    i = 1, ii = 2, iii = 3, iv = 4, v = 5,
    vi = 6, vii = 7, viii = 8, ix = 9, x = 10,
}

local function canonicalName(name)
    local s = normalizeName(name)
    if not s then return nil end

    -- Drop ONE leading category prefix: "dungeon: ", "trial: ", "arena: ".
    -- Anchored, letters and spaces only, so a name that merely contains a colon
    -- is left alone.
    s = s:gsub("^%a[%a%s]*:%s*", "")

    -- Fold a TRAILING roman numeral to arabic, so "grotto i" and "grotto 1"
    -- agree. Only the final token is considered.
    local base, tail = s:match("^(.-)%s+([ivx]+)$")
    if base and base ~= "" and ROMAN_TO_ARABIC[tail] then
        s = base .. " " .. tostring(ROMAN_TO_ARABIC[tail])
    end

    -- Punctuation- and space-blind, as looseName is.
    s = s:gsub("[^%w]", "")
    if s == "" then return nil end
    return s
end

Travel._CanonicalName = canonicalName

-- ---------------------------------------------------------------------------
-- Zone-ID resolution (BUGS.md QMQ-1)
--
-- The name tiers below cannot resolve a group dungeon, and no amount of
-- normalisation will fix that: ESO WAYSHRINES ARE NAMED AFTER PLACES, NOT
-- DUNGEONS. There is no wayshrine called "Fungal Grotto I". So for most group
-- dungeons every name tier misses, FindNodeForActivity correctly returns nil,
-- and the Quartermaster Queue reports "No wayshrine matches it".
--
-- When the activity carries an activityId there is an exact route that needs no
-- names at all. Verified against esoui 12.0.7; none is protected:
--
--     GetActivityZoneId(activityId)            -> zoneId
--     GetFastTravelNodePOIIndicies(nodeIndex)  -> zoneIndex, poiIndex
--     GetZoneId(zoneIndex)                     -> zoneId
--
-- Comparing two integers has no punctuation problem, no ambiguity, and no
-- fuzzy fallback to get wrong.
-- ---------------------------------------------------------------------------

-- The zoneId a node sits in, or nil.
function Travel._NodeZoneId(nodeIndex)
    if type(GetFastTravelNodePOIIndicies) ~= "function" then return nil end
    if type(GetZoneId) ~= "function" then return nil end
    local okIdx, zoneIndex = pcall(GetFastTravelNodePOIIndicies, nodeIndex)
    if not okIdx or type(zoneIndex) ~= "number" then return nil end
    local okZone, zoneId = pcall(GetZoneId, zoneIndex)
    if not okZone or type(zoneId) ~= "number" or zoneId <= 0 then return nil end
    return zoneId
end

-- The zoneId an activity takes place in, or nil.
function Travel._ActivityZoneId(activity)
    if type(activity) ~= "table" then return nil end
    local id = tonumber(activity.activityId)
    if not id or id <= 0 then return nil end
    if type(GetActivityZoneId) ~= "function" then return nil end
    local ok, zoneId = pcall(GetActivityZoneId, id)
    if not ok or type(zoneId) ~= "number" or zoneId <= 0 then return nil end
    return zoneId
end

-- Every node sitting in `zoneId`.
function Travel._NodesInZone(zoneId, total)
    local hits = {}
    if type(zoneId) ~= "number" then return hits end
    for nodeIndex = 1, total do
        if Travel._NodeZoneId(nodeIndex) == zoneId then
            hits[#hits + 1] = nodeIndex
        end
    end
    return hits
end

-- Resolve by zone id. Returns nodeIndex, matchKind or nil.
--
-- STRICT BY DESIGN. This resolves ONLY when the activity's zone contains
-- exactly one usable wayshrine, so the answer is forced rather than chosen.
--
-- An earlier revision also fell back to GetParentZoneId when the activity's own
-- zone held no node. That shipped and was WRONG, in the most expensive way:
-- a dungeon instance's parent is the whole overland zone, which contains many
-- wayshrines including OTHER DUNGEONS' entrances. _PickNode then scored them
-- and confidently returned somebody else's dungeon -- "Bal Sunnar" travelling
-- the player to Fungal Grotto, "Black Drake Villa" to Depths of Malatar.
--
-- That is exactly the failure the name tiers were written to avoid, and the
-- warning was already in this file: "a wrong match teleports the player across
-- the map and charges them gold for it, so silence beats a guess." A wrong
-- destination is far worse than no destination. The fallback is gone and must
-- not come back.
--
-- There is NO activity -> wayshrine API in ESO (verified against esoui 12.0.7:
-- no Get*Activity*Node/POI function exists), so when this tier declines the
-- name tiers run, and if they also decline the caller correctly reports that
-- the dungeon cannot be reached.
function Travel:FindNodeByZone(activity)
    local wantZone = Travel._ActivityZoneId(activity)
    if not wantZone then return nil end

    local total = nodeCount()
    if not total or total < 1 then return nil end

    local hits = Travel._NodesInZone(wantZone, total)

    -- Exactly one node in the activity's own zone is unambiguous: there is
    -- nothing else it could mean. More than one is a CHOICE, and choosing is
    -- what teleported players to the wrong dungeon, so we decline instead.
    if #hits ~= 1 then return nil end

    -- Still require it to be a legal destination.
    local info = nodeInfo and nodeInfo(hits[1]) or nil
    if info and info.known == false then return nil end

    return hits[1], Travel.MATCH_ACTIVITY
end

-- ---------------------------------------------------------------------------
-- Diagnostic probe (BUGS.md QMQ-1)
--
-- Two guesses have now been shipped for this lookup and both were wrong, for
-- the same reason: what a dungeon's fast-travel node is actually CALLED, and
-- whether one exists at all, is GAME DATA. It cannot be read out of esoui
-- source, so it has to be measured on a real client.
--
-- Probe answers exactly that, into the diagnostics ring buffer the player can
-- dump from the settings panel. It changes no behaviour and travels nowhere.
--
-- The single most important number it reports is `dungeonNodes`: how many fast
-- travel nodes carry POI_TYPE_GROUP_DUNGEON.
--   * 0   -> dungeons are NOT fast-travel destinations, and every
--            name/zone approach is doomed. A different mechanism is needed.
--   * ~40 -> they are, and the job is only to match their names correctly.
-- ---------------------------------------------------------------------------

-- All nodes that look like instanced content. Returns { {index, name, known, zone} }.
--
-- Detection is by NAME as well as POI type, because POI type turns out to be
-- unreliable. Traced on hardware:
--     'Dungeon: Fungal Grotto I'  poi=GROUP_DUNGEON
--     'Infinite Archive'  (arena) poi=GROUP_DUNGEON
--     'Maelstrom Arena'   (arena) poi=0
--     "Trial: Sanity's Edge"      poi=3
-- Two arenas report DIFFERENT types, and a trial reports neither dungeon type,
-- so filtering on POI type alone silently omits most instanced content. A node
-- carrying a "<Category>: " prefix is counted regardless of its type.
function Travel:DungeonNodes(limit)
    local out = {}
    local total = nodeCount()
    if not total or total < 1 then return out end
    limit = limit or 500
    for nodeIndex = 1, total do
        local info = nodeInfo(nodeIndex)
        if info then
            local pt = info.poiType
            local byType =
                (POI_TYPE_GROUP_DUNGEON ~= nil and pt == POI_TYPE_GROUP_DUNGEON) or
                (POI_TYPE_PUBLIC_DUNGEON ~= nil and pt == POI_TYPE_PUBLIC_DUNGEON)
            -- A leading "<words>: " marks instanced content whatever its type.
            local byName = type(info.name) == "string"
                           and info.name:find("^%a[%a%s]*:%s") ~= nil
            if byType or byName then
                out[#out + 1] = {
                    index = nodeIndex,
                    name  = info.name,
                    known = info.known,
                    zone  = Travel._NodeZoneId(nodeIndex),
                    poi   = pt,
                }
                if #out >= limit then break end
            end
        end
    end
    return out
end

-- Nodes whose loose name starts with the same prefix as `name`. This is what
-- reveals the naming convention: if the activity is "Fungal Grotto I" and the
-- node turns out to be "Fungal Grotto", a prefix search finds it while an exact
-- match never will.
function Travel:NodesLike(name, prefixLen, limit)
    local out = {}
    local want = looseName(name)
    if not want then return out end
    prefixLen = prefixLen or 6
    limit = limit or 8
    local prefix = want:sub(1, prefixLen)
    if prefix == "" then return out end

    local total = nodeCount()
    if not total or total < 1 then return out end
    for nodeIndex = 1, total do
        local info = nodeInfo(nodeIndex)
        if info then
            local ln = looseName(info.name)
            if ln and ln:sub(1, prefixLen) == prefix then
                out[#out + 1] = {
                    index   = nodeIndex,
                    name    = info.name,
                    known   = info.known,
                    poiType = info.poiType,
                    zone    = Travel._NodeZoneId(nodeIndex),
                }
                if #out >= limit then break end
            end
        end
    end
    return out
end

-- Report everything known about one activity's resolution, into diagnostics.
-- Pure measurement: it does not travel and does not change any state.
function Travel:Probe(activity, report)
    if type(report) ~= "function" then
        report = function(fmt, ...)
            local a = AccountHold
            if a and type(a.Diagnostic) == "function" then
                pcall(a.Diagnostic, a, "info", "[travel/probe] " .. fmt, ...)
            end
        end
    end
    activity = type(activity) == "table" and activity or {}

    local total    = nodeCount() or 0
    local dungeons = Travel:DungeonNodes()
    local actZone  = Travel._ActivityZoneId(activity)

    report("activity=%s id=%s zone=%s",
        tostring(activity.activityName), tostring(activity.activityId), tostring(actZone))
    report("nodes=%d dungeonNodes=%d  <- if dungeonNodes is 0, dungeons are not travel nodes",
        total, #dungeons)

    if actZone then
        local inZone = Travel._NodesInZone(actZone, total)
        report("nodes in that zone=%d", #inZone)
        for i = 1, math.min(#inZone, 4) do
            local info = nodeInfo(inZone[i])
            report("  zone node %d '%s' known=%s",
                inZone[i], tostring(info and info.name), tostring(info and info.known))
        end
    end

    local like = Travel:NodesLike(activity.activityName)
    report("name-prefix candidates=%d", #like)
    for i = 1, #like do
        report("  cand %d '%s' known=%s poi=%s zone=%s",
            like[i].index, tostring(like[i].name), tostring(like[i].known),
            tostring(like[i].poiType), tostring(like[i].zone))
    end

    local node, kind = Travel:FindNodeForActivity(activity)
    report("RESULT node=%s kind=%s", tostring(node), tostring(kind))
    return node, kind
end

-- Choose ONE node from several sharing a name.
--
-- Bailing on ambiguity (the previous behaviour) is why group dungeons reported
-- no destination: a dungeon commonly contributes more than one node -- normal
-- and veteran entrances, or an entrance plus a nearby shrine of the same name.
--
-- Preference order, most to least important:
--   1. discovered (`known`) -- an undiscovered node is not a legal destination
--      anyway, so it must never beat a discovered one
--   2. an actual dungeon POI type -- when a dungeon and a same-named wayshrine
--      both exist, the player asking to run the dungeon wants the dungeon
--   3. lowest node index, purely so the result is deterministic
--
-- Returns nil when the candidates are genuinely indistinguishable, because
-- travelling somewhere arbitrary is worse than saying we don't know.
function Travel._PickNode(hits, infoFn)
    if type(hits) ~= "table" or #hits == 0 then return nil end
    if #hits == 1 then return hits[1] end

    local function rank(nodeIndex)
        local info = infoFn and infoFn(nodeIndex) or nil
        if not info then return -1 end
        local score = 0
        if info.known then score = score + 4 end
        local pt = info.poiType
        if pt ~= nil then
            if (POI_TYPE_GROUP_DUNGEON ~= nil and pt == POI_TYPE_GROUP_DUNGEON)
               or (POI_TYPE_PUBLIC_DUNGEON ~= nil and pt == POI_TYPE_PUBLIC_DUNGEON) then
                score = score + 2
            end
        end
        return score
    end

    local best, bestScore, tied = nil, -1, false
    for _, nodeIndex in ipairs(hits) do
        local score = rank(nodeIndex)
        if score > bestScore then
            best, bestScore, tied = nodeIndex, score, false
        elseif score == bestScore then
            tied = true
        end
    end

    -- A TIE IS ONLY SAFE WHEN THE CANDIDATES ARE THE SAME PLACE.
    --
    -- Two considerations pull against each other here, and both are real:
    --
    --   * A dungeon commonly contributes MORE THAN ONE node -- normal and
    --     veteran entrances, or an entrance plus a same-named shrine. Refusing
    --     outright makes those dungeons unreachable, which is the bug this
    --     function was originally written to fix.
    --   * Picking arbitrarily between two DIFFERENT places is what teleported
    --     players into the wrong dungeon on hardware.
    --
    -- Zone separates the two cases. Tied nodes in the SAME zone are the same
    -- destination however many doors it has, so any of them is a correct
    -- answer. Tied nodes in DIFFERENT zones are different places, and choosing
    -- is a coin flip -- so we decline.
    --
    -- This replaces a "lowest node index" tie-break, which was not a tie-break
    -- at all but a disguised guess.
    if not tied then return best end

    local topZone, sameZone = nil, true
    for _, nodeIndex in ipairs(hits) do
        if rank(nodeIndex) == bestScore then
            local z = Travel._NodeZoneId and Travel._NodeZoneId(nodeIndex) or nil
            if z == nil then sameZone = false break end
            if topZone == nil then topZone = z
            elseif topZone ~= z then sameZone = false break end
        end
    end

    if not sameZone then return nil end

    -- Same place: deterministic choice among equivalent doors.
    local lowest = nil
    for _, nodeIndex in ipairs(hits) do
        if rank(nodeIndex) == bestScore and (lowest == nil or nodeIndex < lowest) then
            lowest = nodeIndex
        end
    end
    return lowest
end

local function buildNameIndex(total)
    if nameIndex and nameIndexCount == total then return nameIndex end
    local map = { exact = {}, loose = {}, canon = {} }
    for i = 1, total do
        local info = nodeInfo(i)
        if info and info.name ~= "" then
            local key = normalizeName(info.name)
            if key then
                local bucket = map.exact[key]
                if not bucket then
                    bucket = {}
                    map.exact[key] = bucket
                end
                bucket[#bucket + 1] = i
            end
            -- Punctuation-blind index, consulted only when the exact one
            -- misses. Built in the same pass so the node list is walked once.
            local loose = looseName(info.name)
            if loose then
                local bucket = map.loose[loose]
                if not bucket then
                    bucket = {}
                    map.loose[loose] = bucket
                end
                bucket[#bucket + 1] = i
            end

            -- Canonical index: category prefix removed, trailing roman numeral
            -- folded to arabic. This is the one that resolves group dungeons --
            -- node "Dungeon: Fungal Grotto 1" and activity "Fungal Grotto I"
            -- meet here and nowhere else.
            local canon = canonicalName(info.name)
            if canon then
                local bucket = map.canon[canon]
                if not bucket then
                    bucket = {}
                    map.canon[canon] = bucket
                end
                bucket[#bucket + 1] = i
            end
        end
    end
    nameIndex      = map
    nameIndexCount = total
    return map
end

-- Additive helper (not in contract D): lets a caller drop the cached name map
-- if it ever needs to, without reaching into module state.
function Travel:InvalidateNodeCache()
    nameIndex      = nil
    nameIndexCount = nil
end

-- Resolve a wayshrine node for an activity record from data/setSources.lua
-- ({ activityKey, activityName, activityType, zoneName, ... }).
--
-- Returns nodeIndex, matchKind -- or nil when no node can be IDENTIFIED.
--
-- Contract note: contract D words this as "nil when not travelable". Per-node
-- travelability (discovered? can we teleport right now? is it outbound-only?)
-- is deliberately left to CanTravelTo, because 0005's acceptance criteria
-- require the row to EXPLAIN why travel is unavailable and a bare nil carries
-- no reason. So nil here means "no node identified"; everything else is a
-- reason code from CanTravelTo.
--
-- No direct "activity -> wayshrine" API exists, so this matches on names, and
-- it is intentionally strict: matching is exact after normalisation, there is
-- no substring or fuzzy fallback, and an ambiguous name resolves to nil. A
-- wrong match teleports the player across the map and charges them gold for it,
-- so silence beats a guess.
function Travel:FindNodeForActivity(activity)
    if type(activity) ~= "table" then return nil end
    -- SetSources emits a synthetic "source unknown" activity for sets with no
    -- database entry. It describes no place, so there is nothing to travel to.
    if activity.activityKey == "unknown" then return nil end

    local total = nodeCount()
    if not total or total < 1 then return nil end

    -- Tier 0: exact zone-id match. Tried FIRST because it is the only tier that
    -- can resolve a group dungeon at all -- wayshrines are named after places,
    -- not dungeons, so every name tier below misses for them (BUGS.md QMQ-1).
    -- Skipped silently when the record has no activityId, which is the case for
    -- data/setSources.lua entries; those fall through to the name tiers.
    local zonePick, zoneKind = Travel:FindNodeByZone(activity)
    if zonePick then return zonePick, zoneKind end

    local wantActivity = normalizeName(activity.activityName)
    local wantZone     = normalizeName(activity.zoneName)
    if not wantActivity and not wantZone then return nil end

    local map = buildNameIndex(total)

    -- Tier 1: a node named after the activity itself.
    --
    -- Multiple hits used to ABORT the whole lookup, which is why group dungeons
    -- reported no destination: a dungeon routinely contributes more than one
    -- node (normal/veteran entrances, or an entrance plus a same-named shrine).
    -- _PickNode disambiguates by discovered-ness and dungeon POI type instead
    -- of giving up.
    if wantActivity then
        local picked = Travel._PickNode(map.exact[wantActivity], nodeInfo)
        if picked then return picked, Travel.MATCH_ACTIVITY end
    end

    -- Tier 1b: same match, punctuation ignored. The activity name comes from
    -- the Item Set Collection category tree and the node name from the travel
    -- list; they disagree on apostrophes and trailing punctuation far more
    -- often than on words.
    local looseActivity = looseName(activity.activityName)
    if looseActivity then
        local picked = Travel._PickNode(map.loose[looseActivity], nodeInfo)
        if picked then return picked, Travel.MATCH_ACTIVITY end
    end

    -- Tier 1c: CANONICAL match -- category prefix stripped, trailing roman
    -- numeral folded to arabic. This is the tier that resolves group dungeons.
    --
    -- The observed mismatch is the node's leading "Dungeon: " (traced on Xbox:
    -- node "Dungeon: Fungal Grotto I" vs activity "Fungal Grotto I"). The
    -- numeral fold is defensive: applied to both sides, so it is agnostic to
    -- whether either spells the number in roman or arabic.
    local canonActivity = canonicalName(activity.activityName)
    if canonActivity then
        local picked = Travel._PickNode(map.canon[canonActivity], nodeInfo)
        if picked then return picked, Travel.MATCH_ACTIVITY end
    end

    -- Tier 2: a node named after the containing zone. This is the O3 case --
    -- some activities have no node of their own, so the best we can do is put
    -- the player in the right zone and let them walk. Reported as MATCH_ZONE so
    -- the UI can label it honestly.
    if wantZone then
        local picked = Travel._PickNode(map.exact[wantZone], nodeInfo)
        if picked then return picked, Travel.MATCH_ZONE end
        local looseZone = looseName(activity.zoneName)
        if looseZone then
            picked = Travel._PickNode(map.loose[looseZone], nodeInfo)
            if picked then return picked, Travel.MATCH_ZONE end
        end
    end

    return nil
end

-- ---------------------------------------------------------------------------
-- Travel legality
-- ---------------------------------------------------------------------------

-- Returns canTravel, reason. Mirrors the gates the base game applies in
-- worldmap.lua's AppendWayshrineTooltip before it will accept a click.
function Travel:CanTravelTo(nodeIndex)
    if type(nodeIndex) ~= "number" or nodeIndex < 1
       or nodeIndex ~= math.floor(nodeIndex) then
        return false, REASON_UNKNOWN_NODE
    end
    if type(GetFastTravelNodeInfo) ~= "function" then
        return false, REASON_NO_API
    end

    local total = nodeCount()
    if total and nodeIndex > total then return false, REASON_UNKNOWN_NODE end

    local info = nodeInfo(nodeIndex)
    if not info or info.name == "" then return false, REASON_UNKNOWN_NODE end

    -- `known` is the discovered flag: an undiscovered shrine is not a legal
    -- destination however the player reached this row.
    if not info.known then return false, REASON_NOT_DISCOVERED end

    -- A wayshrine gated behind a chapter/DLC the account has not unlocked.
    -- Contract D freezes the reason key set, so this and the outbound-only case
    -- below fold into cannot_teleport rather than inventing a sixth key.
    if info.linkedCollectibleIsLocked then return false, REASON_CANNOT_TELEPORT end

    -- Outbound-only nodes can be travelled FROM but never TO (doc :13857 ->
    -- isOutboundOnly, errorStringId). worldmap.lua refuses the click on these.
    -- Both returns are taken even though only the first is used, per the
    -- multi-return rule; the error string id is the base game's own message and
    -- is not surfaced here because contract D fixes our reason vocabulary.
    if type(GetFastTravelNodeOutboundOnlyInfo) == "function" then
        local okOutbound, isOutboundOnly, outboundErrorStringId =
            pcall(GetFastTravelNodeOutboundOnlyInfo, nodeIndex)
        local _ = outboundErrorStringId
        if okOutbound and isOutboundOnly then
            return false, REASON_CANNOT_TELEPORT
        end
    end

    -- Fail CLOSED when the legality check itself is missing. 0005 requires
    -- CanLeaveCurrentLocationViaTeleport (doc :13766) to be honoured, and on a
    -- ToS-critical path "we could not ask" is not "yes".
    if type(CanLeaveCurrentLocationViaTeleport) ~= "function" then
        return false, REASON_NO_API
    end
    local okLeave, canLeave = pcall(CanLeaveCurrentLocationViaTeleport)
    if not okLeave or not canLeave then return false, REASON_CANNOT_TELEPORT end

    return true, REASON_OK
end

-- Recall cost in gold, 0 when unavailable (doc :13874). Surfaced so the player
-- is never surprised by a charge, per 0005's ToS section. Note GetRecallCurrency
-- (:13877) exists and a node can bill in something other than gold; v1 returns
-- the raw number that contract D asks for and leaves currency to the UI epic.
function Travel:GetCost(nodeIndex)
    if type(nodeIndex) ~= "number" then return 0 end
    if type(GetRecallCost) ~= "function" then return 0 end
    local ok, cost = pcall(GetRecallCost, nodeIndex)
    if ok and type(cost) == "number" and cost > 0 then return cost end
    return 0
end

-- ---------------------------------------------------------------------------
-- SHOW ON MAP — the preferred travel path
-- ---------------------------------------------------------------------------
--
-- Opens ESO's own world map focused on the wayshrine, and lets the PLAYER
-- perform the jump through the game's native UI.
--
-- This is strictly safer than TravelTo below, and is what the Priorities screen
-- actually uses. We never call FastTravelToNode at all on this path: the add-on
-- only navigates the map, and the actual travel is the base game's own
-- confirmation flow (which already shows cost and handles every edge case ZOS
-- cares about). There is therefore no automation surface here to defend.
--
-- The pin only exists once the map is showing the node's own zone, so the
-- sequence matters. Verified chain (ESOUIDocumentation.txt, API 101050):
--   GetFastTravelNodePOIIndicies(nodeIndex) :13854 -> zoneIndex, poiIndex
--   GetZoneId(zoneIndex)                    :20562 -> zoneId
--   GetMapIndexByZoneId(zoneId)             :13551 -> mapIndex (nilable)
--   SetMapToMapListIndex(mapIndex)          :13536 -> SetMapResultCode
--   ZO_WorldMap_ShowWorldMap()   esoui/ingame/map/worldmap.lua:3336
--     (picks gamepad_worldMap vs worldMap itself -- do NOT hand-roll that)
--   ZO_WorldMap_PanToWayshrine(nodeIndex)   worldmap.lua:2810
--
-- Every step is optional-guarded: if the map cannot be re-pointed we still open
-- it and pan, and if panning is unavailable the player simply gets the map.
-- Degrading to "map opened, not centred" is acceptable; erroring is not.
--
-- Returns shown, reason.
function Travel:ShowOnMap(nodeIndex)
    if type(nodeIndex) ~= "number" then return false, REASON_UNKNOWN_NODE end

    local info = nodeInfo(nodeIndex)
    if not info then return false, REASON_UNKNOWN_NODE end
    -- An undiscovered wayshrine has no pin to focus and cannot be travelled to,
    -- so say so rather than opening a map that appears to have lost it.
    if not info.known then return false, REASON_NOT_DISCOVERED end

    if type(ZO_WorldMap_ShowWorldMap) ~= "function" then
        return false, REASON_NO_API
    end

    -- Point the map at the node's zone BEFORE showing it.
    --
    -- This MUST go through WORLD_MAP_MANAGER:SetMapByIndex, not the raw
    -- SetMapToMapListIndex. Reported from hardware: "the map opens now, but it's
    -- where the player is, not where the dungeon is."
    --
    -- worldmap.lua keeps a file-local `g_playerChoseCurrentMap`. When the map
    -- scene shows, ZO_MapPanAndZoom:OnWorldMapShowing (:1442-1448) does:
    --
    --     if not g_playerChoseCurrentMap then
    --         SetMapToPlayerLocation()
    --         self:JumpToPin(g_mapPinManager:GetPlayerPin(), USE_CURRENT_ZOOM)
    --     end
    --
    -- ...and it is reset to false every time the map hides (:2455-2459, "the
    -- next time the map opens it will be forced to the player's current
    -- location"). The RAW SetMapToMapListIndex does not touch that flag, so our
    -- carefully chosen map was overwritten a frame later and the pan then found
    -- no wayshrine pin on the player's own map. The manager sets it:
    --
    --     function ZO_WorldMapManager:SetMapByIndex(mapIndex)   -- :4648
    --         if self:IsMapChangingAllowed() then
    --             if SetMapToMapListIndex(mapIndex) == SET_MAP_RESULT_MAP_CHANGED then
    --                 g_playerChoseCurrentMap = true
    --
    -- The set-then-pan pair below is exactly the base game's own wayshrine
    -- navigation (worldmaphouses_gamepad.lua:92-93).
    --
    -- Guarded on the METHOD, never `type(WORLD_MAP_MANAGER) == "table"` --
    -- engine globals are userdata and that test is false on hardware.
    local mapIndex
    if type(GetFastTravelNodePOIIndicies) == "function"
       and type(GetZoneId) == "function"
       and type(GetMapIndexByZoneId) == "function" then
        local okPoi, zoneIndex = pcall(GetFastTravelNodePOIIndicies, nodeIndex)
        if okPoi and type(zoneIndex) == "number" then
            local okZone, zoneId = pcall(GetZoneId, zoneIndex)
            if okZone and type(zoneId) == "number" then
                local okMap, idx = pcall(GetMapIndexByZoneId, zoneId)
                if okMap and type(idx) == "number" then mapIndex = idx end
            end
        end
    end

    if mapIndex then
        local set = false
        if WORLD_MAP_MANAGER ~= nil
           and type(WORLD_MAP_MANAGER.SetMapByIndex) == "function" then
            set = pcall(function() WORLD_MAP_MANAGER:SetMapByIndex(mapIndex) end)
        end
        -- PC-only alias (addoncompatibilityaliases_pc.lua:1208); it forwards to
        -- the same manager call, so it is equivalent where it exists.
        if not set and type(ZO_WorldMap_SetMapByIndex) == "function" then
            set = pcall(ZO_WorldMap_SetMapByIndex, mapIndex)
        end
        -- Last resort. Known NOT to mark the map as player-chosen, so the map
        -- may still snap back to the player -- better than no map at all.
        if not set and type(SetMapToMapListIndex) == "function" then
            pcall(SetMapToMapListIndex, mapIndex)
        end
    end

    local okShow = pcall(ZO_WorldMap_ShowWorldMap)
    if not okShow then return false, REASON_NO_API end

    -- Pan now for the case where the map was already open, and again on the next
    -- frames for the case where we just opened it -- the pin manager has not
    -- necessarily built this map's wayshrine pins yet, and PanToWayshrine
    -- silently does nothing when GetWayshrinePin returns nil
    -- (worldmap.lua:2667-2670). Panning twice to the same pin is a no-op.
    if type(ZO_WorldMap_PanToWayshrine) == "function" then
        pcall(ZO_WorldMap_PanToWayshrine, nodeIndex)
        if type(zo_callLater) == "function" then
            pcall(zo_callLater, function()
                pcall(ZO_WorldMap_PanToWayshrine, nodeIndex)
            end, 100)
        end
    end

    if self.addon and self.addon.Diagnostic then
        self.addon:Diagnostic("info", "[travel] opened map at node %d (%s)",
            nodeIndex, tostring(info.name))
    end
    return true, REASON_OK
end

-- ---------------------------------------------------------------------------
-- THE CHOKEPOINT
-- ---------------------------------------------------------------------------

-- Frame stamp of the last jump. Two jumps inside a single frame cannot both be
-- separate player confirmations -- a human cannot confirm two dialogs in 16ms --
-- so the second is refused. This is what makes "travel every activity in the
-- plan" impossible instead of merely against the rules. Degrades to no guard
-- when the timing API is absent; CanTravelTo still gates every jump.
local lastTravelFrameMs = nil

local function currentFrameMs()
    if type(GetFrameTimeMilliseconds) ~= "function" then return nil end
    local ok, ms = pcall(GetFrameTimeMilliseconds)
    if ok and type(ms) == "number" then return ms end
    return nil
end

-- Perform the jump. Returns performed, reason.
--
-- MUST only ever be called from an explicit player confirmation callback (see
-- the module header). It is never called from anywhere inside this add-on's
-- own code: no event handler, no timer, no refresh, and no other function in
-- this file reaches it.
function Travel:TravelTo(nodeIndex)
    local allowed, reason = self:CanTravelTo(nodeIndex)
    if not allowed then
        if addon and addon.Debug then
            addon:Debug("Travel refused for node %s: %s",
                tostring(nodeIndex), tostring(reason))
        end
        return false, reason
    end

    if type(FastTravelToNode) ~= "function" then
        return false, REASON_NO_API
    end

    local frameMs = currentFrameMs()
    if frameMs and lastTravelFrameMs == frameMs then
        if addon and addon.Diagnostic then
            addon:Diagnostic("warn",
                "Travel refused: a second jump was requested in the same frame.")
        end
        return false, REASON_CANNOT_TELEPORT
    end
    lastTravelFrameMs = frameMs

    -- Audit trail. Travel is the one thing this add-on does that costs the
    -- player money and moves their character, and console players cannot read
    -- Lua errors any other way -- the diagnostics ring buffer is their only
    -- record that every jump was one they asked for.
    if addon and addon.Diagnostic then
        addon:Diagnostic("info", "Travel confirmed by player: node %d.", nodeIndex)
    end

    FastTravelToNode(nodeIndex)
    return true, REASON_OK
end

-- ---------------------------------------------------------------------------
-- Presentation helpers (read-only)
-- ---------------------------------------------------------------------------

-- 0005 requires an unavailable row to say WHY rather than just greying out.
-- Keeping the mapping here means the reason vocabulary and its wording stay in
-- one place when the keyboard and gamepad screens both land.
local REASON_STRING = {
    [REASON_OK]              = { "SI_ACCOUNTHOLD_TRAVEL_OK",              "Travel available" },
    [REASON_UNKNOWN_NODE]    = { "SI_ACCOUNTHOLD_TRAVEL_UNKNOWN_NODE",    "No wayshrine known for this activity" },
    [REASON_NOT_DISCOVERED]  = { "SI_ACCOUNTHOLD_TRAVEL_NOT_DISCOVERED",  "You have not discovered this wayshrine yet" },
    [REASON_CANNOT_TELEPORT] = { "SI_ACCOUNTHOLD_TRAVEL_CANNOT_TELEPORT", "You cannot travel from where you are right now" },
    [REASON_NO_API]          = { "SI_ACCOUNTHOLD_TRAVEL_NO_API",          "Travel is unavailable on this client" },
}

function Travel:GetReasonText(reason)
    local entry = REASON_STRING[reason]
    if not entry then
        return L("SI_ACCOUNTHOLD_TRAVEL_UNKNOWN_NODE",
                 "No wayshrine known for this activity")
    end
    return L(entry[1], entry[2])
end

-- Caveat text for a MATCH_ZONE result (open question O3): the player is being
-- offered the zone's wayshrine, not the activity's door.
function Travel:GetMatchCaveatText(matchKind)
    if matchKind == Travel.MATCH_ZONE then
        return L("SI_ACCOUNTHOLD_TRAVEL_NEARBY_ONLY",
                 "Nearest wayshrine in the zone - you will arrive nearby, not at the entrance")
    end
    return nil
end
