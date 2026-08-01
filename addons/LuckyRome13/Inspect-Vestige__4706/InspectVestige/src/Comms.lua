-- Inspect Vestige by LuckyRome13
-- Comms.lua -- consensual peer loadout sync over the group channel + local cache.
--
-- Transport: LibGroupBroadcast (official group data channel, ~32 bytes/sec, GROUP ONLY).
-- ONE protocol carries everything, multiplexed by a typed LGB VariantField (Serialize.lua owns the
-- schema, IV.BuildLoadoutSchema). The message TYPE is a couple of enum bits, not an ASCII prefix:
--   * build variant (`data.build`) = a bit-packed loadout (TableField; carries an `fr` friends-only
--     flag inside it, so there's no separate FR marker)
--   * req   variant (`data.req`)   = an inspect request: the target's group index (1..24)
--   * fo    variant (`data.fo`)    = a friends-only refusal ("I only share with friends")
--   * hi    variant (`data.hi`)    = a presence beacon ("I run this addon")
-- Flow (on-demand request/response, to respect the shared channel):
--   1. Inspect grouped player X -> Send { req = X's group index }.
--   2. Every group addon receives it; only X (matching index) responds by broadcasting its
--      encoded build. (Broadcast is inherent to the channel; only opted-in data.)
--   3. Requester matches the responder's unit tag -> @account -> pending request, and hands
--      the decoded build to the window. Any build we see is also cached.
-- Verified working end-to-end between two accounts (real group, both running the addon).
--
-- WIRE FORMAT: v3 typed/bit-packed fields (was v2's ASCII "IV2;..." string), ~2x smaller and
-- quicker to trickle. This reuses protocol id 420 with a NEW schema, so a v2 (old) peer and a v3 peer
-- CANNOT decode each other -- both sides must update. LGB silently ignores frames for an UNKNOWN
-- id, but a same-id/changed-schema frame from an old peer just fails to decode (logged, no crash).
--
-- API matches LibGroupBroadcast's official reference (doc/api_reference.txt). This is the **2.x**
-- API -- the manifest pins LibGroupBroadcast>=95 (v2.0.0) because a 1.x exposes a different one and
-- would fail into the pcall below, silently disabling peer sync:
--   LGB:RegisterHandler(name) -> handler
--   handler:DeclareProtocol(id, name) -> protocol
--   protocol:AddField(IV.BuildLoadoutSchema(LGB)) -> protocol   (a single VariantField)
--   protocol:OnData(function(unitTag, data) ... end) ; protocol:Finalize(opts) ; protocol:Send(values)
-- LibGroupBroadcast is a REQUIRED dependency (see the manifest) -- it IS the peer-inspect feature,
-- so the addon shouldn't load at all without it rather than silently degrade to self-inspect only.
-- The nil-check + pcall below are belt-and-suspenders: if the lib somehow fails to load or its API
-- shifts, peer sync disables itself (Comms.ready = false) instead of hard-erroring.
-- The protocol id shares a global 9-bit space (0-511, NUM_ID_BITS = 9). PROTOCOL_LOADOUT_ID is
-- RESERVED on the ESOUI registration page (https://wiki.esoui.com/LibGroupBroadcast_IDs) -- do not
-- change it, and keep it in range (an out-of-range id asserts "too large for 9 bits" at send time).
-- Multiplexing everything above onto this one protocol is why we only need the single id.
-- (Payloads larger than 30 bytes are auto-split/reassembled by the library.)

local IV = InspectVestige
IV.Comms = IV.Comms or {}
local Comms = IV.Comms

Comms.ready = false

local PROTOCOL_LOADOUT_ID   = 420 -- LGB protocol id (0-511); reserved on the wiki https://wiki.esoui.com/LibGroupBroadcast_IDs
local PROTOCOL_COSMETICS_ID = 421 -- SECOND reserved id: cosmetics ride their own channel (change far less often)
local FRIENDS_SIG_MARKER  = "FR;" -- prefix on the dedup signature only, so toggling friends-only counts as a change
local REQUEST_TIMEOUT_MS  = 8000

local loadoutProtocol            -- LGB protocol object (set in Init)
local cosmeticsProtocol          -- LGB protocol object for the cosmetics channel (set in Init)
local scheduleBroadcast          -- fwd decl (defined in the proactive section; used by announceBack)
local scheduleCosmetics          -- fwd decl (cosmetics proactive push; used by announceBack)

local pending = {}               -- [atAccount] = { onResult = fn, timerName = string }

local function dbg(msg)
    if IV.sv and IV.sv.debug then d("|cFFD700[IV]|r " .. tostring(msg)) end
end

--------------------------------------------------------------------------------
-- Group helpers
--------------------------------------------------------------------------------
local function getSelfGroupIndex()
    local size = GetGroupSize()
    for i = 1, size do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and AreUnitsEqual(tag, "player") then
            return i
        end
    end
    return 0
end

-- Our friends list as a set of @accounts.
local function friendSet()
    local set = {}
    for i = 1, (GetNumFriends and GetNumFriends() or 0) do
        local acc = GetFriendInfo(i)
        if acc and acc ~= "" then set[acc] = true end
    end
    return set
end

local function isFriendUnit(unitTag)
    local acc = unitTag and GetUnitDisplayName(unitTag)
    if not acc or acc == "" then return false end
    return friendSet()[acc] == true
end

-- Is anyone in the group on our friends list? Send-time optimisation only (skip a pointless
-- broadcast); the RECEIVER is what actually enforces friends-only, so this never has to stay in
-- sync with the group while a message is in flight.
local function hasFriendInGroup()
    local set = friendSet()
    for i = 1, (GetGroupSize() or 0) do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and not AreUnitsEqual(tag, "player") then
            local acc = GetUnitDisplayName(tag)
            if acc and set[acc] then return true end
        end
    end
    return false
end

-- With "share with friends only" on, just MARK the build (the encoded `fr` flag); don't name
-- recipients. Group indices are positional and shift the moment anyone joins/leaves, and a build
-- takes ~15s to trickle out over the ~32 B/s channel -- so a recipient list can go stale mid-flight
-- and address the wrong player. Instead the RECEIVER decides: ESO friendship is mutual, so "is the
-- sender on MY friends list?" answers "am I on theirs?" exactly, evaluated at receive time against
-- the live list. LGB still delivers to the whole group, so this is a convention every copy of the
-- addon honours -- NOT encryption.
--   Returns: "all"  -> send the build unmarked (friends-only off)
--            "fr"   -> send it with fr=true (friends-only on, a friend is in the group)
--            nil    -> send nothing (friends-only on, nobody in the group to share with)
local function friendsShareMode()
    if not (IV.sv and IV.sv.friendsOnly) then return "all" end
    if not hasFriendInGroup() then return nil end
    return "fr"
end

--------------------------------------------------------------------------------
-- Presence: which group members run this addon. LGB has NO presence/handshake API, so we learn
-- peers from any message we receive AND from a tiny "HI" beacon each member sends on group-join.
-- The PROACTIVE broadcast path is gated on this being non-empty -- a full build never goes out to a
-- group where nobody else can use it (the reviewer's "keep the pipeline free"). On-demand responses
-- ignore presence (a REQ proves the asker has the addon).
--------------------------------------------------------------------------------
local seenAddonPeers = {}   -- [@account] = true, excluding us; reset when the group changes

-- Record a peer; returns true only if this is the FIRST time we've seen them (a discovery edge).
local function noteAddonPeer(unitTag)
    local acc = unitTag and GetUnitDisplayName(unitTag)
    if not acc or acc == "" or acc == GetDisplayName() then return false end
    if seenAddonPeers[acc] then return false end
    seenAddonPeers[acc] = true
    return true
end
local function hasAddonPeer()   return next(seenAddonPeers) ~= nil end
local function clearAddonPeers() for k in pairs(seenAddonPeers) do seenAddonPeers[k] = nil end end

-- A peer just contacted us (HI / build). Record them; if they're NEWLY discovered and we proactively
-- share, push our current build once so they cache it. The send is presence-gated + rate-limited, so
-- a burst of joins coalesces, and the newness check stops A<->B from ping-ponging builds forever.
local function announceBack(unitTag)
    if noteAddonPeer(unitTag) and IV.sv and IV.sv.proactiveShare then
        scheduleBroadcast(true, "peer-discovered")
        if scheduleCosmetics then scheduleCosmetics(true, "peer-discovered") end   -- push cosmetics too, so they cache
    end
end

--------------------------------------------------------------------------------
-- Incoming: someone asked for a build. Respond only if it's asking for US and the
-- user hasn't opted out of sharing.
--------------------------------------------------------------------------------
local function onRequestReceived(unitTag, targetIndex)
    if not IV.sv or IV.sv.respondToRequests == false then
        return
    end
    if targetIndex ~= getSelfGroupIndex() then
        return
    end
    if not loadoutProtocol then return end

    -- Sharing with friends only, and this asker isn't one: say so explicitly rather than leaving
    -- them on a silent timeout that looks like the addon is broken. No addressee needed -- each
    -- receiver decides if it applies to them (see the dispatcher).
    if IV.sv.friendsOnly and not isFriendUnit(unitTag) then
        dbg("refusing request from non-friend -- friends-only is on")
        pcall(function() loadoutProtocol:Send({ fo = true }) end)
        return
    end

    local mode = friendsShareMode()
    if not mode then return end   -- friends-only on, no friend in the group -> share nothing
    dbg("responding to request")
    pcall(function()
        loadoutProtocol:Send({ build = IV.EncodeBuild(IV.BuildOwnBuildPayload(), mode == "fr") })
    end)
end

-- The target shares with friends only and we're not on their list.
local function onFriendsOnlyRefused(unitTag)
    local atAccount = GetUnitDisplayName(unitTag)
    local waiting   = atAccount and pending[atAccount]
    if not waiting then return end
    dbg(("%s shares with friends only"):format(tostring(atAccount)))
    pending[atAccount] = nil
    if waiting.timerName then EVENT_MANAGER:UnregisterForUpdate(waiting.timerName) end
    if waiting.onRefused then waiting.onRefused() end
end

--------------------------------------------------------------------------------
-- Cache is a single per-account entry shared by BOTH channels: { build, cos, name, ts, cosTs }.
-- Each channel updates its OWN field in place (never replace the whole entry, or the loadout
-- broadcast would wipe cached cosmetics and vice versa).
--------------------------------------------------------------------------------
local function cacheEntry(atAccount)
    if not (IV.cache and IV.cache.entries and atAccount and atAccount ~= "") then return nil end
    local e = IV.cache.entries[atAccount]
    if type(e) ~= "table" then e = {}; IV.cache.entries[atAccount] = e end
    return e
end

-- Attach a peer's cached cosmetics (decoded table) onto a loadout for display. The Window resolves
-- the raw refs at draw time (IV.StyleCollectibleForOsid), so this is a plain hand-off.
local function attachCachedCosmetics(loadout)
    local acc = loadout and loadout.meta and loadout.meta.atAccount
    local e = acc and IV.cache and IV.cache.entries and IV.cache.entries[acc]
    if e and type(e.cos) == "table" then loadout.cosmetics = e.cos end
end
IV.Comms.AttachCachedCosmetics = attachCachedCosmetics

--------------------------------------------------------------------------------
-- Incoming: a build arrived. Cache it, and resolve any pending request for it.
--------------------------------------------------------------------------------
local function onLoadoutReceived(unitTag, buildValues)
    local build = IV.DecodeBuild(buildValues)
    if not build then return end

    local atAccount = GetUnitDisplayName(unitTag)
    local name      = GetUnitName(unitTag)
    dbg(("received loadout from %s"):format(tostring(atAccount)))

    -- Cache the DECODED build table keyed by account (per-server store, see IV.cache in Main.lua).
    -- Update in place so a cached cosmetics record on this entry survives.
    local e = cacheEntry(atAccount)
    if e then e.build = build; e.name = name; e.ts = GetTimeStamp() end

    -- Build a peer loadout only if someone's actually waiting on / looking at this player:
    -- a pending request, OR the inspect window is currently open on them (so an unsolicited
    -- update -- e.g. their weapon-swap push -- live-refreshes the open window, not just cache).
    local waiting     = atAccount and pending[atAccount]
    local showingThis = IV.Window and IV.Window.IsShowingAccount and IV.Window.IsShowingAccount(atAccount)
    if not (waiting or showingThis) then return end

    -- Merge live public meta from the sender's unit tag with the shared build.
    local loadout = IV.BuildPublicInfo(unitTag) or IV.BuildNameOnlyInfo(atAccount, name)
    IV.OverlayBuild(loadout, build)
    attachCachedCosmetics(loadout)   -- fold in their cached cosmetics (may arrive on the other channel)
    loadout.meta.source = "peer"
    loadout.meta.ts     = GetTimeStamp()

    if waiting then
        pending[atAccount] = nil
        if waiting.timerName then EVENT_MANAGER:UnregisterForUpdate(waiting.timerName) end
        if waiting.onResult then waiting.onResult(loadout) end
    else
        IV.Window.Show(loadout)   -- window open on this player -> live-refresh it in place
    end
end

--------------------------------------------------------------------------------
-- Cosmetics channel (protocol 421). Same shape as the build channel but simpler: no timeout/refusal
-- UI (the build channel already tells the user about friends-only), so a cosmetics request is
-- fire-and-forget -- the reply merges into the open window (or just the cache) when it lands.
--------------------------------------------------------------------------------

-- Someone asked US for our cosmetics. Respond only if it's for us and we haven't opted out of sharing.
local function onCosmeticsRequestReceived(unitTag, targetIndex)
    if not IV.sv or IV.sv.respondToRequests == false then return end
    if targetIndex ~= getSelfGroupIndex() then return end
    if not cosmeticsProtocol then return end
    -- Friends-only + not a friend: stay silent. The build channel's `fo` already surfaced the
    -- friends-only status to them, so an empty cosmetics view is self-explanatory.
    if IV.sv.friendsOnly and not isFriendUnit(unitTag) then return end
    local mode = friendsShareMode()
    if not mode then return end   -- friends-only on, no friend in the group -> share nothing
    dbg("responding to cosmetics request")
    pcall(function()
        cosmeticsProtocol:Send({ cos = IV.EncodeCosmetics(IV.ReadOwnCosmetics(), mode == "fr") })
    end)
end

-- A peer's cosmetics arrived. Cache them (in place) and, if we're looking at that player, fold them
-- into the open window and re-render. Cosmetics carry no meta -- they only enrich an existing card.
local function onCosmeticsReceived(unitTag, cosValues)
    local cos = IV.DecodeCosmetics(cosValues)
    if not cos then return end

    local atAccount = GetUnitDisplayName(unitTag)
    dbg(("received cosmetics from %s"):format(tostring(atAccount)))

    local e = cacheEntry(atAccount)
    if e then e.cos = cos; e.cosTs = GetTimeStamp() end

    -- Live-refresh only if the window is currently open on this player.
    if IV.Window and IV.Window.IsShowingAccount and atAccount and IV.Window.IsShowingAccount(atAccount)
       and IV.Window.GetShown then
        local loadout = IV.Window.GetShown()
        if loadout then
            loadout.cosmetics = cos
            IV.Window.Show(loadout)
        end
    end
end

--------------------------------------------------------------------------------
-- Init: bind LibGroupBroadcast (guarded)
--------------------------------------------------------------------------------
function Comms.Init()
    local LGB = _G.LibGroupBroadcast
    if not LGB then
        dbg("LibGroupBroadcast not present -- peer sync disabled")
        return
    end

    local ok, err = pcall(function()
        local handler = LGB:RegisterHandler(IV.name)

        -- ONE protocol carries builds, inspect requests, refusals, and presence beacons, multiplexed
        -- by a typed VariantField (IV.BuildLoadoutSchema owns the schema in Serialize.lua). Keeps us
        -- to a single reserved id (no second protocol). LGB fragments a build across the ~32 B/s
        -- channel; a decoded variant arrives under its own label (data.req/hi/fo/build).
        loadoutProtocol = handler:DeclareProtocol(PROTOCOL_LOADOUT_ID, IV.name .. "Loadout")
        loadoutProtocol:AddField(IV.BuildLoadoutSchema(LGB))
        loadoutProtocol:OnData(function(unitTag, data)
            if type(data) ~= "table" then return end
            -- Inspect request: the asker runs the addon (we reply directly; no proactive push).
            if data.req then
                noteAddonPeer(unitTag)
                onRequestReceived(unitTag, data.req)
                return
            end
            -- Presence beacon: the sender announced they run the addon. announceBack records them and,
            -- if they're new + we proactively share, pushes our build so they cache it.
            if data.hi then
                announceBack(unitTag)
                return
            end
            -- "I only share with friends." Broadcast, so each receiver decides whether it applies:
            -- a friend of the sender ignores it (their build is on the way), anyone else is refused.
            if data.fo then
                noteAddonPeer(unitTag)
                if not isFriendUnit(unitTag) then onFriendsOnlyRefused(unitTag) end
                return
            end
            -- A build. Its `fr` flag means the sender shares with friends only: LGB hands it to the
            -- whole group regardless, so honour the sender's intent here -- keep it only if the SENDER
            -- is on our friends list (mutual, so that's the same as us being on theirs). Everyone else
            -- drops it, never cached / shown. Checked against the live list, so it can't go stale.
            if data.build then
                if data.build.fr and not isFriendUnit(unitTag) then return end
                announceBack(unitTag)   -- a build proves the sender runs the addon (mutual share if new)
                onLoadoutReceived(unitTag, data.build)
            end
        end)
        -- isRelevantInCombat=false (LGB's default): a loadout is NOT combat-critical, so LGB holds
        -- our sends until the sender leaves combat, leaving the shared ~30 B/s frame budget free for
        -- combat addons (Hodor etc.). replaceQueuedMessages=false: this protocol is MULTIPLEXED
        -- (request + build + presence all share the id), and replace would drop a queued REQ when a
        -- build is sent (or vice versa). Our own dedup + 20s rate-limit already prevent build
        -- pile-ups, so we don't want the collapse. (The earlier code omitted this believing "unset =
        -- off", but LGB defaults replaceQueuedMessages to TRUE -- it must be set false explicitly.)
        loadoutProtocol:Finalize({ isRelevantInCombat = false, replaceQueuedMessages = false })

        -- Harden inbound decode. LGB decodes a received message with our schema in Protocol:Receive
        -- BEFORE our OnData runs, and there's no hook we can guard around it. If that decode ever
        -- fails, a NumericField read runs PAST THE END OF THE BUFFER and asserts -- which surfaces to
        -- the player as a client error box. Two real ways it fails on a shared, lossy channel:
        --   (1) A frame LOST mid-flight (a zone load drops one) -- LGB's reassembly appends any
        --       continuation frame for the id with NO sequence check (FrameHandler CanAppendMessage),
        --       so a missing MIDDLE frame isn't detected: it finalizes a TRUNCATED buffer and decodes
        --       it. Our ~14-frame build maximises this. (Reported: both peers erroring on zone-in.)
        --   (2) A foreign / old-format (v1.0.0 "IV2;...") message on our shared id 420 decodes as
        --       garbage and over-reads the same way.
        -- We can't fix LGB, but Receive runs on OUR protocol instance, so wrap it in a pcall: an
        -- undecodable message is DROPPED (the right thing for a corrupt packet -- the sender re-shares
        -- on its next change and on-demand inspects re-request) instead of throwing. A well-formed
        -- same-version message always decodes (the schema is deterministic), so this only ever
        -- swallows the genuinely-bad ones.
        local rawReceive = loadoutProtocol.Receive
        loadoutProtocol.Receive = function(self, unitTag, message)
            local ok2, err2 = pcall(rawReceive, self, unitTag, message)
            if not ok2 then dbg("dropped an undecodable inbound message: " .. tostring(err2)) end
        end

        -- SECOND protocol (id 421): cosmetics. Its own channel so it's decoupled from the frequent
        -- loadout broadcast -- it only fires when a style/collectible actually changes. Two variants
        -- (req | cos), so like the loadout it's multiplexed -> replaceQueuedMessages=false.
        cosmeticsProtocol = handler:DeclareProtocol(PROTOCOL_COSMETICS_ID, IV.name .. "Cosmetics")
        cosmeticsProtocol:AddField(IV.BuildCosmeticsSchema(LGB))
        cosmeticsProtocol:OnData(function(unitTag, data)
            if type(data) ~= "table" then return end
            if data.req then
                noteAddonPeer(unitTag)
                onCosmeticsRequestReceived(unitTag, data.req)
                return
            end
            -- Cosmetics payload: honour the sender's friends-only intent exactly like a build.
            if data.cos then
                if data.cos.fr and not isFriendUnit(unitTag) then return end
                announceBack(unitTag)   -- proves the sender runs the addon (mutual share if newly seen)
                onCosmeticsReceived(unitTag, data.cos)
            end
        end)
        cosmeticsProtocol:Finalize({ isRelevantInCombat = false, replaceQueuedMessages = false })

        -- Same inbound-decode hardening as the loadout channel (a lost/foreign frame must not assert).
        local rawReceiveC = cosmeticsProtocol.Receive
        cosmeticsProtocol.Receive = function(self, unitTag, message)
            local okc, errc = pcall(rawReceiveC, self, unitTag, message)
            if not okc then dbg("dropped an undecodable cosmetics message: " .. tostring(errc)) end
        end
    end)

    Comms.ready = ok and true or false
    if not ok then
        dbg("LibGroupBroadcast bind failed (verify API) -- peer sync disabled: " .. tostring(err))
        loadoutProtocol = nil
        cosmeticsProtocol = nil
    else
        dbg("peer sync ready")
    end
end

--------------------------------------------------------------------------------
-- Public: request a grouped player's cosmetics. Fire-and-forget -- the reply merges into the open
-- window (or just the cache) via onCosmeticsReceived; no callbacks/timeout (the build channel owns
-- the "syncing / friends-only / no data" UI).
--------------------------------------------------------------------------------
function Comms.RequestCosmetics(atAccount, targetUnitTag)
    if not Comms.ready or not cosmeticsProtocol then return false end
    local targetIndex = GetGroupIndexByUnitTag and GetGroupIndexByUnitTag(targetUnitTag)
    if not targetIndex or targetIndex == 0 then
        for i = 1, (GetGroupSize() or 0) do
            if AreUnitsEqual(GetGroupUnitTagByIndex(i), targetUnitTag) then targetIndex = i break end
        end
    end
    if not targetIndex or targetIndex == 0 then return false end
    dbg(("requesting cosmetics for %s (index %d)"):format(tostring(atAccount), targetIndex))
    pcall(function() cosmeticsProtocol:Send({ req = targetIndex }) end)
    return true
end

--------------------------------------------------------------------------------
-- Public: request a grouped player's loadout.
--   onResult(loadout) is called on success; onTimeout() if nobody answers.
--------------------------------------------------------------------------------
function Comms.RequestLoadout(atAccount, targetUnitTag, onResult, onTimeout, onRefused)
    if not Comms.ready or not loadoutProtocol then
        if onTimeout then onTimeout() end
        return false
    end

    local targetIndex = GetGroupIndexByUnitTag and GetGroupIndexByUnitTag(targetUnitTag)
    if not targetIndex or targetIndex == 0 then
        -- Fall back to scanning for the index.
        local size = GetGroupSize()
        for i = 1, size do
            if AreUnitsEqual(GetGroupUnitTagByIndex(i), targetUnitTag) then targetIndex = i break end
        end
    end
    if not targetIndex or targetIndex == 0 then
        if onTimeout then onTimeout() end
        return false
    end

    -- Register pending + timeout.
    local timerName = "InspectVestigeReq_" .. atAccount
    pending[atAccount] = { onResult = onResult, onRefused = onRefused, timerName = timerName }
    EVENT_MANAGER:RegisterForUpdate(timerName, REQUEST_TIMEOUT_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(timerName)
        if pending[atAccount] then
            pending[atAccount] = nil
            if onTimeout then onTimeout() end
        end
    end)

    dbg(("requesting loadout for %s (index %d)"):format(atAccount, targetIndex))
    pcall(function() loadoutProtocol:Send({ req = targetIndex }) end)
    return true
end

-- Return a decoded, cached loadout for an account (or nil). Pass a live unit tag
-- (group tag / reticleover) so the card carries public meta (class/race/CP/...) rather
-- than name-only; the "Cached <x> ago" indicator then lives on the status line, not in
-- place of that info.
function Comms.GetCached(atAccount, unitTag)
    local entry = IV.cache and IV.cache.entries and IV.cache.entries[atAccount]
    if not entry or type(entry.build) ~= "table" then return nil end   -- table guard also drops old string-cache entries
    local build = entry.build

    local loadout = (unitTag and IV.BuildPublicInfo(unitTag))
                    or IV.BuildNameOnlyInfo(atAccount, entry.name)
    IV.OverlayBuild(loadout, build)
    attachCachedCosmetics(loadout)   -- fold in cached cosmetics too, if we have them
    loadout.meta.source = "cache"
    loadout.meta.ts = entry.ts
    return loadout
end

-- Timestamp of the cached entry for an account (or nil) -- lets the inspect router
-- decide whether a live refresh is worth the channel traffic.
function Comms.GetCacheTimestamp(atAccount)
    local entry = IV.cache and IV.cache.entries and IV.cache.entries[atAccount]
    return entry and entry.ts or nil
end

-- Do we already hold this player's cosmetics? Cosmetics change rarely, so the inspect router only
-- requests them when we DON'T -- once cached, proactive pushes keep them current.
function Comms.HasCachedCosmetics(atAccount)
    local entry = IV.cache and IV.cache.entries and IV.cache.entries[atAccount]
    return (entry and type(entry.cos) == "table") or false
end

--------------------------------------------------------------------------------
-- Proactive sharing: push our loadout to the group on join / change so members have
-- it cached before they inspect. Reuses loadoutProtocol (broadcasts to the group);
-- receivers cache it via onLoadoutReceived. Same privacy gate as request/response.
--------------------------------------------------------------------------------
local BROADCAST_DEBOUNCE_MS    = 8000     -- coalesce a burst of loadout edits into ONE broadcast:
                                          -- every change re-arms this timer, so actively swapping
                                          -- gear (equip, look, equip) settles into a single send
                                          -- ~8s after the LAST change instead of one per piece.
                                          -- Proactive freshness isn't urgent (on-demand inspects
                                          -- encode fresh + aren't debounced), so a longer wait is fine.
local BROADCAST_MIN_INTERVAL_MS = 20000   -- hard cap: never proactively broadcast more than once
                                          -- per 20s. A full build takes ~16s to trickle out over
                                          -- the ~32 B/s channel, so bursts of triggers (rapid
                                          -- wayshrine TPs, the buff storm on every zone load) must
                                          -- NOT each fire a send -- that floods the channel and the
                                          -- server disconnects the client.
local LOAD_GRACE_MS = 8000                -- and suppress entirely during / just after a load screen
local BROADCAST_TIMER = "InspectVestigeBroadcast"
local lastBroadcastSig
local lastBroadcastAt = 0
local pendingForce = false
local pendingReason               -- short label of the trigger that armed the timer (debug log only)

-- Zone-load state: EVENT_PLAYER_ACTIVATED fires after each load screen (registered in
-- InitAutoShare). We treat the player as "loading" until activated, plus a grace window after --
-- long enough that rapid back-to-back TPs never leave the loading state between them.
local playerActivated = true
local zoneLoadedAt = 0
function Comms.IsLoading()
    return (not playerActivated) or (GetGameTimeMilliseconds() - zoneLoadedAt) < LOAD_GRACE_MS
end

-- Gate for the PROACTIVE path only (BroadcastLoadout). The on-demand response (onRequestReceived)
-- sends directly and is NOT gated by this.
local function canBroadcast()
    return Comms.ready and loadoutProtocol
        and (GetGroupSize() or 0) > 1
        and not (IV.sv and IV.sv.respondToRequests == false)   -- sharing fully off
        and not (IV.sv and IV.sv.proactiveShare == false)      -- proactive opted out (on-demand only)
        and hasAddonPeer()                                     -- someone in the group can actually use it
end

-- Send our current build now (respecting gates). force ignores the no-change check.
-- reason is a short string for the debug log only (which trigger drove this send).
function Comms.BroadcastLoadout(force, reason)
    if not canBroadcast() then return end
    local mode = friendsShareMode()
    if not mode then return end   -- friends-only on, no friend in the group -> share nothing
    local friendsOnly = (mode == "fr")
    local build = IV.BuildOwnBuildPayload()
    -- Only a REAL loadout change (gear/skills/CP/attrs/mundus/food/curse) may re-send. IV.SignatureOf
    -- strips the volatile bits -- stats (every buff moves them) and each gear record's condCharge
    -- (durability/enchant charge tick down nonstop in combat) -- which otherwise made this check
    -- always true: a zone load re-sent per wayshrine, and a dungeon re-sent every ~20s forever.
    -- Prefix the friends-only marker so toggling that setting still counts as a change. A friend
    -- JOINING doesn't need to move the signature -- EVENT_GROUP_MEMBER_JOINED force-sends anyway.
    local sig = (friendsOnly and FRIENDS_SIG_MARKER or "") .. IV.SignatureOf(build)
    if not force and sig == lastBroadcastSig then return end   -- no real change; skip
    -- Diagnostic: forced sends bypass the dedup, so log WHY; on a sig change, log old vs new so the
    -- exact field that moved is visible (a flickering sig would show up here).
    if IV.sv and IV.sv.debug then
        if force then
            dbg(("broadcast: FORCED (%s)"):format(reason or "?"))
        elseif lastBroadcastSig == nil then
            dbg(("broadcast: first (%s)"):format(reason or "?"))
        else
            dbg(("broadcast: CHANGED (%s)\n  old=%s\n  new=%s"):format(reason or "?",
                tostring(lastBroadcastSig), tostring(sig)))
        end
    end
    lastBroadcastSig = sig
    lastBroadcastAt  = GetGameTimeMilliseconds()
    pcall(function() loadoutProtocol:Send({ build = IV.EncodeBuild(build, friendsOnly) }) end)
end

local function fireBroadcast()
    EVENT_MANAGER:UnregisterForUpdate(BROADCAST_TIMER)
    -- Defer while in combat or loading, and rate-limit: coalesce bursts into at most one send
    -- per BROADCAST_MIN_INTERVAL_MS. (Re-arming a timer is cheap; sending during a load storm
    -- is what gets us disconnected.)
    local wait
    if IsUnitInCombat("player") or Comms.IsLoading() then
        wait = BROADCAST_DEBOUNCE_MS
    else
        local sinceLast = GetGameTimeMilliseconds() - lastBroadcastAt
        if sinceLast < BROADCAST_MIN_INTERVAL_MS then wait = BROADCAST_MIN_INTERVAL_MS - sinceLast end
    end
    if wait then
        EVENT_MANAGER:RegisterForUpdate(BROADCAST_TIMER, wait, fireBroadcast)
        return
    end
    local f = pendingForce
    local r = pendingReason
    pendingForce = false
    pendingReason = nil
    Comms.BroadcastLoadout(f, r)
end

-- Debounced trigger: coalesces rapid changes; sticky force survives interleaved events.
-- reason is a short label for the debug log (latest one wins). (Assigns the forward-declared
-- local so announceBack, defined earlier, can call it.)
function scheduleBroadcast(force, reason)
    if not canBroadcast() then return end
    if force then pendingForce = true end
    if reason then pendingReason = reason end
    EVENT_MANAGER:UnregisterForUpdate(BROADCAST_TIMER)
    EVENT_MANAGER:RegisterForUpdate(BROADCAST_TIMER, BROADCAST_DEBOUNCE_MS, fireBroadcast)
end

--------------------------------------------------------------------------------
-- Proactive COSMETICS sharing (protocol 421) -- mirrors the loadout broadcast on its own state +
-- dedup. Cosmetics change rarely, so after the initial share this almost never fires; the same
-- combat/load deferral + rate-limit keep it a good citizen of the shared channel. Reuses the
-- loadout debounce/interval constants (a cosmetics payload is small, so this is conservative).
--------------------------------------------------------------------------------
local COSMETICS_TIMER = "InspectVestigeCosmetics"
local lastCosmeticsSig
local lastCosmeticsAt = 0
local pendingCosForce = false

local function canBroadcastCosmetics()
    return Comms.ready and cosmeticsProtocol
        and (GetGroupSize() or 0) > 1
        and not (IV.sv and IV.sv.respondToRequests == false)
        and not (IV.sv and IV.sv.proactiveShare == false)
        and hasAddonPeer()
end

-- Send our current cosmetics now (respecting gates). force ignores the no-change dedup.
local function BroadcastCosmetics(force)
    if not canBroadcastCosmetics() then return end
    local mode = friendsShareMode()
    if not mode then return end   -- friends-only on, no friend in the group -> share nothing
    local friendsOnly = (mode == "fr")
    local cos = IV.ReadOwnCosmetics()
    -- Nothing in cosmetics is volatile (no stats/durability), so the whole signature is the dedup.
    -- Prefix the friends-only marker so toggling that setting still counts as a change.
    local sig = (friendsOnly and FRIENDS_SIG_MARKER or "") .. IV.CosmeticsSignatureOf(cos)
    if not force and sig == lastCosmeticsSig then return end
    if IV.sv and IV.sv.debug then
        dbg(force and "cosmetics broadcast: FORCED"
            or (lastCosmeticsSig == nil and "cosmetics broadcast: first" or "cosmetics broadcast: CHANGED"))
    end
    lastCosmeticsSig = sig
    lastCosmeticsAt  = GetGameTimeMilliseconds()
    pcall(function() cosmeticsProtocol:Send({ cos = IV.EncodeCosmetics(cos, friendsOnly) }) end)
end

local function fireCosmetics()
    EVENT_MANAGER:UnregisterForUpdate(COSMETICS_TIMER)
    local wait
    if IsUnitInCombat("player") or Comms.IsLoading() then
        wait = BROADCAST_DEBOUNCE_MS
    else
        local sinceLast = GetGameTimeMilliseconds() - lastCosmeticsAt
        if sinceLast < BROADCAST_MIN_INTERVAL_MS then wait = BROADCAST_MIN_INTERVAL_MS - sinceLast end
    end
    if wait then
        EVENT_MANAGER:RegisterForUpdate(COSMETICS_TIMER, wait, fireCosmetics)
        return
    end
    local f = pendingCosForce
    pendingCosForce = false
    BroadcastCosmetics(f)
end

-- Debounced cosmetics trigger (assigns the forward-declared local so announceBack can call it).
-- reason is currently debug-only context; the cosmetics dedup makes over-firing harmless.
function scheduleCosmetics(force, reason)
    if not canBroadcastCosmetics() then return end
    if force then pendingCosForce = true end
    EVENT_MANAGER:UnregisterForUpdate(COSMETICS_TIMER)
    EVENT_MANAGER:RegisterForUpdate(COSMETICS_TIMER, BROADCAST_DEBOUNCE_MS, fireCosmetics)
end
Comms.ScheduleCosmetics = scheduleCosmetics

-- Presence beacon "HI" -- announces "I run this addon" so peers can share with us and we can gate
-- proactive builds. Tiny (2 bytes); sent on group-join, debounced to coalesce join bursts + the
-- zone-load re-fires of EVENT_GROUP_MEMBER_JOINED. Not gated on hasAddonPeer (it's how discovery
-- STARTS), but skipped for a fully-private user (respondToRequests off) and during a load screen.
-- Combat needs no check: isRelevantInCombat=false means LGB already holds it until combat ends.
local HELLO_TIMER = "InspectVestigeHello"
local HELLO_DEBOUNCE_MS = 3000   -- HI is tiny + presence discovery shouldn't lag; keep it snappy
                                 -- and independent of the (longer) loadout-broadcast debounce.
local function sendHello()
    if not (Comms.ready and loadoutProtocol) then return end
    if (GetGroupSize() or 0) <= 1 then return end
    if IV.sv and IV.sv.respondToRequests == false then return end
    if Comms.IsLoading() then return end
    dbg("announcing presence (HI)")
    pcall(function() loadoutProtocol:Send({ hi = true }) end)
end
local function scheduleHello()
    EVENT_MANAGER:UnregisterForUpdate(HELLO_TIMER)
    EVENT_MANAGER:RegisterForUpdate(HELLO_TIMER, HELLO_DEBOUNCE_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(HELLO_TIMER)
        sendHello()
    end)
end
-- Exposed so Loadout can force a push when a weapon bar is newly captured (a pure stat
-- change the non-stat dedup would otherwise swallow).
Comms.ScheduleBroadcast = scheduleBroadcast

-- Register the group-join + loadout-change triggers.
function Comms.InitAutoShare()
    if not Comms.ready then return end
    local ok = pcall(function()
        local em = EVENT_MANAGER
        local ns = IV.name .. "Share"

        -- Load-screen tracking (gates broadcasts so a zone-load buff storm / rapid TPs can't
        -- trigger a flood of sends that disconnects us).
        em:RegisterForEvent(ns, EVENT_PLAYER_DEACTIVATED, function() playerActivated = false end)
        em:RegisterForEvent(ns, EVENT_PLAYER_ACTIVATED, function()
            playerActivated = true
            zoneLoadedAt = GetGameTimeMilliseconds()
        end)

        -- Join -> announce presence (HI), NOT a blind full-build broadcast. Discovery is mutual:
        -- peers who receive our HI (or we theirs) push their build via announceBack. This means a
        -- group with no other addon user gets zero full-build traffic. (Old behaviour force-broadcast
        -- the whole build on every join AND on every zone-load re-fire of this event.)
        em:RegisterForEvent(ns, EVENT_GROUP_MEMBER_JOINED, scheduleHello)

        -- Member left -> forget them; if we left / the group emptied, drop all known peers so a new
        -- group starts discovery fresh (and proactive broadcasting gates off until someone's found).
        em:RegisterForEvent(ns, EVENT_GROUP_MEMBER_LEFT, function(_, _, _, isLocalPlayer, _, displayName)
            if displayName then seenAddonPeers[displayName] = nil end
            if isLocalPlayer or (GetGroupSize() or 0) <= 1 then clearAddonPeers() end
        end)

        -- Loadout changes -> debounced push (reason = debug label); the signature dedups no-op
        -- events (durability ticks, combat procs that don't alter the serialized build).
        local function trigger(reason) return function() scheduleBroadcast(false, reason) end end
        -- Ignore durability + enchant-charge ticks: they fire nonstop in combat (every enchant proc)
        -- and never change the loadout. Belt-and-braces with SignatureOf dropping condCharge.
        em:RegisterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, _, _, _, _, reason)
            if reason ~= INVENTORY_UPDATE_REASON_DURABILITY_CHANGE
               and reason ~= INVENTORY_UPDATE_REASON_ITEM_CHARGE then
                scheduleBroadcast(false, "gear")
            end
        end)
        em:AddFilterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
        em:RegisterForEvent(ns, EVENT_ACTION_SLOT_ABILITY_SLOTTED, trigger("skill"))
        em:RegisterForEvent(ns, EVENT_CHAMPION_PURCHASE_RESULT, trigger("cp"))
        em:RegisterForEvent(ns, EVENT_ATTRIBUTE_UPGRADE_UPDATED, trigger("attr"))
        -- (Weapon swap isn't listed here: a swap only changes stats, which the dedup ignores.
        -- When a swap NEWLY captures a bar, Loadout forces a push via Comms.ScheduleBroadcast.)
        -- EVENT_EFFECT_CHANGED fires for EVERY buff, so react ONLY to the food/mundus effects that
        -- are actual loadout changes (IV.IsLoadoutEffect, same test the stat-capture side uses) and
        -- bail in combat/loading. Reacting to every buff re-armed the broadcast debounce nonstop in
        -- combat and ran BuildOwnBuildPayload/SignatureOf on each -- pure churn (the sig deduped the
        -- send, but the work and timer-thrash were needless). Matches the Loadout side exactly now.
        em:RegisterForEvent(ns, EVENT_EFFECT_CHANGED, function(_, _, _, effectName, _, _, _, _, iconName)
            if Comms.IsLoading() then return end
            if IsUnitInCombat("player") then return end
            if IV.IsLoadoutEffect and IV.IsLoadoutEffect(effectName, iconName) then
                scheduleBroadcast(false, "food/mundus")
            end
        end)
        em:AddFilterForEvent(ns, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

        -- Cosmetic changes -> debounced push on the SEPARATE cosmetics channel (scheduleCosmetics),
        -- so restyling an outfit or swapping a costume/hat re-shares ONLY the cosmetics, never the
        -- loadout. We cast a wide net (outfit + collectible events) because the cosmetics dedup makes
        -- an over-fire harmless (it just re-arms a debounce; the actual send is skipped if nothing
        -- changed), and guard each constant so a name that doesn't exist on an older client is skipped.
        local function cosTrigger() scheduleCosmetics(false, "cosmetics") end
        for _, evName in ipairs({
            "EVENT_OUTFIT_CHANGED", "EVENT_OUTFIT_EQUIP_RESPONSE",
            "EVENT_COLLECTIBLE_UPDATED", "EVENT_COLLECTION_UPDATED", "EVENT_COLLECTIBLE_USE_RESULT",
        }) do
            local ev = rawget(_G, evName)
            if ev then em:RegisterForEvent(ns, ev, cosTrigger) end
        end

        -- Loaded while already in a group (e.g. /reloadui) -> no JOINED event fires, so announce once
        -- to (re)discover peers. Debounced, so it settles after the reload storm.
        if (GetGroupSize() or 0) > 1 then scheduleHello() end
    end)
    dbg("auto-share " .. (ok and "registered" or "failed to register"))
end

--------------------------------------------------------------------------------
-- Debug: simulate a group inspect of yourself, no second account needed.
--------------------------------------------------------------------------------
-- Encodes our own build EXACTLY as we'd broadcast it (join / loadout-change) into the transmit
-- value-shape, decodes it back, and shows it as a "peer" -- exercising the full encode -> decode ->
-- display mapping (everything but the LibGroupBroadcast bit-packing hop). Cosmetics round-trip the
-- SAME way (through IV.Encode/DecodeCosmetics), so the receiver-side osid->collectible resolution is
-- exercised too. The name is tweaked so it's obviously a simulated other player.
function Comms.TestGroupInspect()
    local build = IV.DecodeBuild(IV.EncodeBuild(IV.BuildOwnBuildPayload(), false))
    if not build then
        d("|cff6666[IV test]|r build failed to round-trip -- encode/decode bug")
        return
    end
    -- Same assembly onLoadoutReceived does for a live peer, but forced to show.
    local loadout = IV.BuildPublicInfo("player")
                    or IV.BuildNameOnlyInfo(GetUnitDisplayName("player"), GetUnitName("player"))
    IV.OverlayBuild(loadout, build)
    -- Round-trip cosmetics through the wire format too (exercises the peer resolve-at-display path).
    loadout.cosmetics = IV.DecodeCosmetics(IV.EncodeCosmetics(IV.ReadOwnCosmetics(), false))
    loadout.meta = loadout.meta or {}
    loadout.meta.source    = "peer"
    loadout.meta.ts        = GetTimeStamp()
    loadout.meta.name      = ((loadout.meta.name ~= "" and loadout.meta.name) or "Tester") .. " [TEST PEER]"
    loadout.meta.atAccount = "@GroupInspectTest"
    IV.Window.Show(loadout)
    d("|cffd700[IV test]|r round-tripped build + cosmetics -> shown as simulated peer")
end
