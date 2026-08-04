local C = Conductor
local SRC = SupportRotationCallouts
C.Network = C.Network or {}
local Network = C.Network

Network.protocolVersion = 3
Network.capabilitySchemaVersion = 5
Network.discoveryProtocolId = 238
Network.discoveryProtocolName = "CONDUCTOR_DISCOVERY_V1_DEV"
Network.discoveryIntervalMs = 5000
Network.enabled = true
Network.transportReady = false
Network.peers = Network.peers or {}
Network.pending = Network.pending or {}
Network.revision = Network.revision or 0
Network.lastSentSignature = nil
Network.outboundQueue = Network.outboundQueue or {}
Network.rejectReasons = Network.rejectReasons or {}
Network.stats = Network.stats or {
    sent = 0, received = 0, rejected = 0, duplicatePackets = 0, stalePackets = 0,
    timedOutProfiles = 0, rosterDiscoveries = 0, profilesCompleted = 0,
    profileChangesSent = 0, profileSendsSuppressed = 0, normalizedProfilesCompleted = 0,
    normalizedEntriesSent = 0, normalizedEntriesReceived = 0, startedAt = 0, lastSyncAt = 0,
    transportInitAttempts = 0, transportRecoveries = 0, lastTransportAttemptAt = 0,
    lastSendAt = 0, lastReceiveAt = 0, rosterMembers = 0, queuedChunks = 0,
    partialProfilesCommitted = 0, profileCommits = 0, retryPacketsSent = 0,
}

local FIELD_SEP = "|"
local ENTRY_SEP = ";"
local VALUE_SEP = "^"
local ESCAPE_MAP = { ["%"] = "%25", ["|"] = "%7C", [";"] = "%3B", ["^"] = "%5E" }
local PROFILE_SEND_DEBOUNCE_MS = 450
local CHUNK_SEND_INTERVAL_MS = 325
local RETRY_PASS_DELAY_MS = 1500
local PARTIAL_COMMIT_DELAY_MS = 1200
local PENDING_TIMEOUT_MS = 15000
local MIN_PROFILE_SEND_INTERVAL_MS = 1000

local function IsProtocolEnabled(protocol)
    return protocol and (not protocol.IsEnabled or protocol:IsEnabled())
end

local function Now()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Escape(value)
    return (tostring(value or ""):gsub("[%%|;^]", ESCAPE_MAP))
end

local function Unescape(value)
    return tostring(value or ""):gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

local function Split(text, separator)
    local result, start = {}, 1
    text = tostring(text or "")
    while true do
        local pos = string.find(text, separator, start, true)
        if not pos then
            result[#result + 1] = string.sub(text, start)
            break
        end
        result[#result + 1] = string.sub(text, start, pos - 1)
        start = pos + #separator
    end
    return result
end

local function GetAccountForUnit(unitTag)
    local raw = tostring(unitTag or "")
    if raw:sub(1, 1) == "@" then return raw end
    if raw ~= "" and GetUnitDisplayName then
        local name = GetUnitDisplayName(raw)
        if name and name ~= "" then return name end
    end
    return ""
end

local function CompactRole(role)
    role = string.upper(tostring(role or "UNKNOWN"))
    if role == "LEAD" or role == "TRIAL LEAD" then return "L" end
    if role == "SUPPORT" then return "S" end
    if role == "DAMAGE" or role == "DAMAGE DEALER" or role == "DD" then return "D" end
    return "U"
end

local function ExpandRole(role)
    if role == "L" then return "LEAD" end
    if role == "S" then return "SUPPORT" end
    if role == "D" then return "DAMAGE" end
    return "UNKNOWN"
end

local function AddUnique(target, seen, value)
    value = tostring(value or "")
    if value ~= "" and not seen[value] then
        seen[value] = true
        target[#target + 1] = value
    end
end

local function HashText(text)
    local hash = 5381
    text = tostring(text or "")
    for index = 1, #text do
        hash = (hash * 33 + string.byte(text, index)) % 2147483647
    end
    return tostring(hash)
end

function Network:Reject(reason)
    reason = tostring(reason or "unknown")
    self.stats.rejected = (self.stats.rejected or 0) + 1
    self.rejectReasons[reason] = (self.rejectReasons[reason] or 0) + 1
    self.lastRejectReason = reason
    return false
end

local function ResolveProviderForSource(source)
    if not source then return "", nil end
    local explicit = tostring(source.providerKey or source.key or "")
    if explicit ~= "" then
        local provider = C.KnowledgeBase and C.KnowledgeBase.GetProvider and C.KnowledgeBase:GetProvider(explicit) or nil
        -- Dynamic Scribing providers are intentionally compositional and do not
        -- require a pre-enumerated provider registry entry.
        return tostring(provider and provider.key or explicit), provider
    end
    if C.KnowledgeBase and C.KnowledgeBase.FindProviderByDisplayName then
        local provider = C.KnowledgeBase:FindProviderByDisplayName(source.name or "")
        if provider then return tostring(provider.key or ""), provider end
    end
    return "", nil
end

function Network:NormalizeCapability(capability, source)
    local capabilityKey = tostring(capability and capability.key or "")
    local effect = C.KnowledgeBase and C.KnowledgeBase:GetEffect(capabilityKey) or nil
    local effectKey = effect and tostring(effect.key or capabilityKey) or capabilityKey
    local providerKey = select(1, ResolveProviderForSource(source))
    local responsibilityKeys, seen = {}, {}
    if C.KnowledgeBase then
        for _, responsibility in ipairs(C.KnowledgeBase:GetResponsibilitiesForEffect(effectKey) or {}) do
            AddUnique(responsibilityKeys, seen, responsibility.key)
        end
        if providerKey ~= "" then
            for _, responsibility in ipairs(C.KnowledgeBase:GetResponsibilitiesProvidedBy(providerKey) or {}) do
                AddUnique(responsibilityKeys, seen, responsibility.key)
            end
        end
    end
    if capability and capability.responsibilityKey then AddUnique(responsibilityKeys, seen, capability.responsibilityKey) end
    table.sort(responsibilityKeys)
    return {
        key = capabilityKey, effectKey = effectKey,
        category = tostring(capability and capability.category or "SUPPORT"),
        name = tostring(capability and capability.name or (effect and effect.name) or capabilityKey),
        confidence = tostring(capability and capability.confidence or "CONFIRMED"),
        providerKey = providerKey, providerName = tostring(source and source.name or ""),
        sourceType = tostring(source and source.type or "UNKNOWN"),
        responsibilityKeys = responsibilityKeys, normalized = true,
    }
end

function Network:BuildNormalizedCapabilities(snapshot)
    local output, seen = {}, {}
    local capabilities = snapshot and snapshot.capabilities or {}
    for _, capability in ipairs(capabilities.interpreted or {}) do
        local sources = capability.sources or {}
        if #sources == 0 then sources = { { type = "UNKNOWN", name = "" } } end
        for _, source in ipairs(sources) do
            local normalized = self:NormalizeCapability(capability, source)
            local signature = table.concat({ normalized.effectKey, normalized.providerKey, table.concat(normalized.responsibilityKeys, ","), normalized.sourceType }, "|")
            if not seen[signature] then
                seen[signature] = true
                output[#output + 1] = normalized
            end
        end
    end
    table.sort(output, function(a, b)
        return tostring(a.effectKey) .. "|" .. tostring(a.providerKey) < tostring(b.effectKey) .. "|" .. tostring(b.providerKey)
    end)
    if snapshot and snapshot.capabilities then snapshot.capabilities.normalized = output end
    return output
end

local function CompactCategory(category)
    category = string.upper(tostring(category or "SUPPORT"))
    if category == "BUFF" then return "B" end
    if category == "DEBUFF" then return "D" end
    if category == "ULTIMATE" then return "U" end
    return "S"
end

local function ExpandCategory(category)
    if category == "B" then return "BUFF" end
    if category == "D" then return "DEBUFF" end
    if category == "U" then return "ULTIMATE" end
    if category == "S" then return "SUPPORT" end
    return tostring(category or "SUPPORT")
end

local function CompactSourceType(sourceType)
    sourceType = string.upper(tostring(sourceType or "UNKNOWN"))
    if sourceType == "GEAR" or sourceType == "SET" or sourceType == "MONSTER_SET" then return "G" end
    if sourceType == "SKILL" then return "S" end
    if sourceType == "ULTIMATE" then return "U" end
    if sourceType == "ENCHANTMENT" then return "E" end
    if sourceType == "CLASS" then return "C" end
    if sourceType == "SCRIBING" or sourceType == "SCRIBED_SKILL" or sourceType == "SCRIPT" then return "B" end
    return "N"
end

local function ExpandSourceType(sourceType)
    if sourceType == "G" then return "GEAR" end
    if sourceType == "S" then return "SKILL" end
    if sourceType == "U" then return "ULTIMATE" end
    if sourceType == "E" then return "ENCHANTMENT" end
    if sourceType == "C" then return "CLASS" end
    if sourceType == "B" then return "SCRIBING" end
    if sourceType == "N" then return "NETWORK" end
    return tostring(sourceType or "NETWORK")
end

function Network:BuildEntries(snapshot)
    local entries = {}
    for _, capability in ipairs(self:BuildNormalizedCapabilities(snapshot)) do
        -- Schema 4 uses only stable IDs on the wire. Display names, categories,
        -- and responsibilities are reconstructed from the local Knowledge Base.
        -- This significantly reduces chunk count and avoids classification drift.
        entries[#entries + 1] = table.concat({
            Escape(capability.effectKey or capability.key),
            Escape(capability.providerKey),
            CompactSourceType(capability.sourceType)
        }, VALUE_SEP)
    end
    table.sort(entries)
    return entries
end

function Network:BuildProfileSignature(snapshot, entries)
    return HashText(table.concat({
        tostring(snapshot and snapshot.classId or 0),
        CompactRole(snapshot and snapshot.role),
        table.concat(entries or {}, ENTRY_SEP),
    }, FIELD_SEP))
end

function Network:BuildChunks(snapshot, entries)
    entries = entries or self:BuildEntries(snapshot)
    local chunks, current = {}, ""
    local limit = (C.NetworkTransport and C.NetworkTransport.MAX_PAYLOAD or 190) - 42
    for _, entry in ipairs(entries) do
        local candidate = current == "" and entry or (current .. ENTRY_SEP .. entry)
        if #candidate > limit and current ~= "" then
            chunks[#chunks + 1] = current
            current = entry
        else
            current = candidate
        end
    end
    if current ~= "" or #chunks == 0 then chunks[#chunks + 1] = current end

    local payloads, revision, count = {}, self.revision, #chunks
    for index, body in ipairs(chunks) do
        payloads[#payloads + 1] = table.concat({
            "P3", tostring(revision), tostring(index), tostring(count),
            tostring(snapshot.classId or 0), CompactRole(snapshot.role),
            Escape(C.Platform and C.Platform.version or C.version or ""), body
        }, FIELD_SEP)
    end
    return payloads
end

function Network:DeclareDiscoveryProtocol()
    if self.discoveryProtocol then return true end
    local LGB = LibGroupBroadcast
    local handler = C.NetworkTransport and C.NetworkTransport.handler
    if not LGB or not handler then return false, "Conductor discovery handler unavailable" end

    local ok, protocolOrError = pcall(function()
        local protocol = handler:DeclareProtocol(self.discoveryProtocolId, self.discoveryProtocolName)
        protocol:AddField(LGB.CreateStringField("version", { minLength=1, maxLength=24 }))
        protocol:AddField(LGB.CreateNumericField("protocol", { numBits=8, trimValues=true }))
        protocol:AddField(LGB.CreateNumericField("schema", { numBits=8, trimValues=true }))
        protocol:OnData(function(unitTag, values) self:OnDiscovery(unitTag, values) end)
        protocol:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=true })
        return protocol
    end)
    if not ok then
        self.discoveryError = tostring(protocolOrError)
        return false, self.discoveryError
    end
    self.discoveryProtocol = protocolOrError
    self.discoveryError = nil
    return true
end

function Network:OnDiscovery(unitTag, values)
    local sender = GetAccountForUnit(unitTag)
    if sender == "" then return end
    local localName = GetDisplayName and GetDisplayName() or ""
    if localName ~= "" and string.lower(sender) == string.lower(localName) then return end
    if C.LiveSession and not C.LiveSession:IsAccountPresent(sender) then return end

    local remoteProtocol = tonumber(values and values.protocol) or 0
    local remoteSchema = tonumber(values and values.schema) or 0
    local compatibility = remoteProtocol == self.protocolVersion and "COMPATIBLE" or "INCOMPATIBLE"
    local key = string.lower(sender)
    local existing = self.peers[key] or {}
    existing.accountName = sender
    existing.version = tostring(values and values.version or "unknown")
    existing.protocol = remoteProtocol
    existing.capabilitySchema = remoteSchema
    existing.compatibility = compatibility
    existing.lastSeenAt = Now()
    existing.unitTag = unitTag
    existing.profileState = existing.profileState or "DISCOVERED"
    existing.discoveryOnly = existing.profileState == "DISCOVERED"
    self.peers[key] = existing
    self.stats.rosterDiscoveries = (self.stats.rosterDiscoveries or 0) + 1
    self.stats.lastReceiveAt = Now()
    self.stats.lastSyncAt = self.stats.lastReceiveAt
    if C.EventBus then C.EventBus:Publish("NETWORK_PEER_DISCOVERED", { accountName=sender, peer=existing }) end
end

function Network:BroadcastDiscovery()
    if not self.enabled or not SRC.saved or SRC.saved.enabled ~= true then return false end
    if not IsUnitGrouped or not IsUnitGrouped("player") then return false end
    if not self.discoveryProtocol then
        local declared = self:DeclareDiscoveryProtocol()
        if not declared then return false end
    end
    if not IsProtocolEnabled(self.discoveryProtocol) then return false end
    local ok, queued = pcall(self.discoveryProtocol.Send, self.discoveryProtocol, {
        version=tostring(C.Platform and C.Platform.version or SRC.version or "unknown"),
        protocol=self.protocolVersion,
        schema=self.capabilitySchemaVersion,
    })
    if ok and queued ~= false then
        self.lastDiscoverySentAt = Now()
        return true
    end
    self.discoveryError = tostring(queued or "discovery message was not queued")
    return false
end

function Network:EnsureTransportReady(force)
    if not self.enabled or not C.NetworkTransport then return false end
    if self.transportReady and C.NetworkTransport:CanSendConductorPayloads() and not force then return true end
    self.stats.transportInitAttempts = (self.stats.transportInitAttempts or 0) + 1
    self.stats.lastTransportAttemptAt = Now()
    local wasReady = self.transportReady == true
    self.transportReady = C.NetworkTransport:Initialize(function(unitTag, payload)
        self:ParsePayload(unitTag, payload)
    end, force == true) == true
    if self.transportReady then self:DeclareDiscoveryProtocol() end
    if self.transportReady and not wasReady then self.stats.transportRecoveries = (self.stats.transportRecoveries or 0) + 1 end
    return self.transportReady
end

function Network:SuspendForSessionTransfer()
    self.transferSuspended = true
    self.sendGeneration = (self.sendGeneration or 0) + 1
    self.resumeSnapshot = C.PlayerScanner and C.PlayerScanner:GetLastLocalSnapshot() or self.resumeSnapshot
    return true
end

function Network:ResumeAfterSessionTransfer()
    self.transferSuspended = false
    local snapshot = self.resumeSnapshot or (C.PlayerScanner and C.PlayerScanner:GetLastLocalSnapshot())
    self.resumeSnapshot = nil
    if snapshot then self:ScheduleSnapshot(snapshot, false, "session_transfer_complete") end
    if #self.outboundQueue > 0 then self:ProcessOutboundQueue() end
end

function Network:ProcessOutboundQueue()
    -- LibGroupBroadcast cannot queue group traffic when the player is not grouped.
    -- Treat solo play as a dormant network state rather than a transport failure.
    if not IsUnitGrouped or not IsUnitGrouped("player") then
        self.outboundQueue = {}
        self.outboundRetry = nil
        self.outboundSending = false
        self.stats.queuedChunks = 0
        self.lastSendError = nil
        return
    end
    if self.transferSuspended or (C.NetworkTransport and C.NetworkTransport:IsBlockedFor("PROFILE")) then return end
    if self.outboundSending then return end
    if #self.outboundQueue == 0 then return end
    local transfer = C.SessionTransfer and C.SessionTransfer.outgoing
    if transfer and transfer.state ~= "SENT" then
        zo_callLater(function() Network:ProcessOutboundQueue() end, 500)
        return
    end
    self.outboundSending = true
    local function sendNext()
        if self.transferSuspended or (C.NetworkTransport and C.NetworkTransport:IsBlockedFor("PROFILE")) then
            self.outboundSending = false
            return
        end
        local item = table.remove(self.outboundQueue, 1)
        self.stats.queuedChunks = #self.outboundQueue
        if not item then
            self.outboundSending = false
            return
        end
        local sent, sendError = C.NetworkTransport:Send(item.payload, "PROFILE")
        if sent then
            self.stats.sent = (self.stats.sent or 0) + 1
            self.stats.lastSendAt = Now()
        else
            self:Reject("send_failed")
            self.lastSendError = tostring(sendError or "unknown send failure")
        end
        if #self.outboundQueue > 0 then
            zo_callLater(sendNext, CHUNK_SEND_INTERVAL_MS)
        else
            self.outboundSending = false
            local retry = self.outboundRetry
            self.outboundRetry = nil
            if retry and retry.revision == self.revision and not retry.scheduled then
                retry.scheduled = true
                zo_callLater(function()
                    if retry.revision ~= self.revision or #self.outboundQueue > 0 or self.outboundSending then return end
                    for _, payload in ipairs(retry.payloads or {}) do
                        self.outboundQueue[#self.outboundQueue + 1] = { payload = payload, revision = retry.revision, retry = true }
                    end
                    self.stats.queuedChunks = #self.outboundQueue
                    self.stats.retryPacketsSent = (self.stats.retryPacketsSent or 0) + #self.outboundQueue
                    self:ProcessOutboundQueue()
                end, RETRY_PASS_DELAY_MS)
            end
        end
    end
    sendNext()
end

function Network:QueueSnapshot(snapshot, force)
    if not self.enabled or not snapshot then return false end
    if not IsUnitGrouped or not IsUnitGrouped("player") then
        self.outboundQueue = {}
        self.outboundRetry = nil
        self.stats.queuedChunks = 0
        return false
    end
    if self.transferSuspended or (C.NetworkTransport and C.NetworkTransport:IsBlockedFor("PROFILE")) then
        self.resumeSnapshot = snapshot
        return false
    end
    if not self:EnsureTransportReady(false) then return false end

    local entries = self:BuildEntries(snapshot)
    local signature = self:BuildProfileSignature(snapshot, entries)
    if signature == self.lastSentSignature then
        self.stats.profileSendsSuppressed = (self.stats.profileSendsSuppressed or 0) + 1
        return false
    end
    local now = Now()
    if not force and now - (self.stats.lastSendAt or 0) < MIN_PROFILE_SEND_INTERVAL_MS then
        self:ScheduleSnapshot(snapshot, false, "rate_limit")
        return false
    end

    self.revision = (self.revision + 1) % 65535
    local payloads = self:BuildChunks(snapshot, entries)
    self.outboundQueue = {}
    for _, payload in ipairs(payloads) do self.outboundQueue[#self.outboundQueue + 1] = { payload = payload, revision = self.revision } end
    self.outboundRetry = { revision = self.revision, payloads = payloads, scheduled = false }
    self.stats.queuedChunks = #self.outboundQueue
    self.stats.profileChangesSent = (self.stats.profileChangesSent or 0) + 1
    self.stats.normalizedEntriesSent = (self.stats.normalizedEntriesSent or 0) + #entries
    self.stats.lastSyncAt = now
    self.lastSentSignature = signature
    self:ProcessOutboundQueue()
    return true
end


function Network:QueueControlPayload(payload)
    if not self.enabled or tostring(payload or "") == "" then return false end
    if not IsUnitGrouped or not IsUnitGrouped("player") then return false end
    if self.transferSuspended or (C.NetworkTransport and C.NetworkTransport:IsBlockedFor("PROFILE")) then return false end
    if not self:EnsureTransportReady(false) then return false end
    self.outboundQueue[#self.outboundQueue + 1] = { payload = tostring(payload), control = true }
    self.stats.queuedChunks = #self.outboundQueue
    self:ProcessOutboundQueue()
    return true
end

function Network:ScheduleSnapshot(snapshot, force, reason)
    self.sendGeneration = (self.sendGeneration or 0) + 1
    local generation = self.sendGeneration
    self.scheduledReason = reason or "change"
    zo_callLater(function()
        if generation ~= self.sendGeneration then return end
        local current = snapshot or (C.PlayerScanner and C.PlayerScanner:GetLastLocalSnapshot())
        if current then self:QueueSnapshot(current, force == true) end
    end, PROFILE_SEND_DEBOUNCE_MS)
end

function Network:ParsePayload(unitTag, payload)
    payload = tostring(payload or "")
    if payload == "" then return self:Reject("empty_payload") end

    -- Raid Session sharing uses dedicated LibGroupBroadcast protocols.

    local fields = Split(payload, FIELD_SEP)
    if fields[1] ~= "P3" or #fields < 8 then return self:Reject("invalid_envelope") end

    local sender = GetAccountForUnit(unitTag)
    if sender == "" then return self:Reject("unknown_sender") end
    if C.LiveSession and not C.LiveSession:IsAccountPresent(sender) then
        self.stats.stalePackets = (self.stats.stalePackets or 0) + 1
        return self:Reject("sender_not_in_live_group")
    end
    local localName = GetDisplayName and GetDisplayName() or ""
    if localName ~= "" and string.lower(sender) == string.lower(localName) then
        -- LibGroupBroadcast echoes local sends. This is expected transport
        -- behavior, not a duplicate remote packet.
        return true
    end

    local revision = tonumber(fields[2]) or 0
    local chunkIndex = tonumber(fields[3]) or 0
    local chunkCount = tonumber(fields[4]) or 0
    if chunkIndex < 1 or chunkCount < 1 or chunkIndex > chunkCount or chunkCount > 24 then return self:Reject("invalid_chunk") end

    local key = string.lower(sender)
    local pending = self.pending[key]
    if pending and revision < pending.revision and (pending.revision - revision) < 32000 then
        self.stats.stalePackets = (self.stats.stalePackets or 0) + 1
        return true
    end
    if not pending or pending.revision ~= revision then
        pending = {
            revision = revision, chunkCount = chunkCount, chunks = {}, received = 0,
            classId = tonumber(fields[5]) or 0, role = ExpandRole(fields[6]),
            version = Unescape(fields[7]), unitTag = unitTag, startedAt = Now(), lastChunkAt = Now(),
        }
        self.pending[key] = pending
    elseif pending.chunkCount ~= chunkCount then
        return self:Reject("chunk_count_mismatch")
    end

    if pending.chunks[chunkIndex] then
        self.stats.duplicatePackets = (self.stats.duplicatePackets or 0) + 1
        return true
    end
    pending.chunks[chunkIndex] = fields[8] or ""
    pending.received = pending.received + 1
    pending.lastChunkAt = Now()

    self.stats.received = (self.stats.received or 0) + 1
    self.stats.lastReceiveAt = Now()
    self.stats.lastSyncAt = self.stats.lastReceiveAt
    self.peers[key] = {
        accountName = sender, version = pending.version, protocol = self.protocolVersion,
        compatibility = "COMPATIBLE", lastSeenAt = self.stats.lastSyncAt, unitTag = unitTag,
        revision = revision, chunksReceived = pending.received, chunksExpected = chunkCount,
        profileState = pending.received >= chunkCount and "COMPLETE" or "ASSEMBLING",
    }

    if pending.received >= pending.chunkCount then return self:CompleteProfile(sender, pending, false) end

    -- Incrementally merge every valid chunk into the live remote profile.
    -- This prevents a client from exposing only the first partial chunk.
    self:CompleteProfile(sender, pending, true)
    return true
end

local function ResolveResponsibilities(effectKey, providerKey)
    local out, seen = {}, {}
    if C.KnowledgeBase then
        for _, responsibility in ipairs(C.KnowledgeBase:GetResponsibilitiesForEffect(effectKey) or {}) do
            AddUnique(out, seen, responsibility.key)
        end
        if providerKey ~= "" then
            for _, responsibility in ipairs(C.KnowledgeBase:GetResponsibilitiesProvidedBy(providerKey) or {}) do
                AddUnique(out, seen, responsibility.key)
            end
        end
    end
    table.sort(out)
    return out
end

function Network:DecodeEntry(encodedEntry, partial)
    local values = Split(encodedEntry, VALUE_SEP)
    if not values[1] or values[1] == "" then return nil end

    local effectKey, providerKey, sourceType, sourceName, responsibilityKeys, category
    if #values <= 3 then
        -- Capability schema 4: effectKey ^ providerKey ^ sourceType
        effectKey = Unescape(values[1])
        providerKey = Unescape(values[2])
        sourceType = ExpandSourceType(Unescape(values[3]))
        responsibilityKeys = ResolveResponsibilities(effectKey, providerKey)
    else
        -- Capability schema 3 compatibility.
        sourceName = Unescape(values[4])
        providerKey = Unescape(values[5])
        responsibilityKeys = {}
        local encodedResponsibilities = Unescape(values[6])
        if encodedResponsibilities ~= "" then
            for _, responsibilityKey in ipairs(Split(encodedResponsibilities, ",")) do
                if responsibilityKey ~= "" then responsibilityKeys[#responsibilityKeys + 1] = responsibilityKey end
            end
        end
        effectKey = Unescape(values[7])
        if effectKey == "" then effectKey = Unescape(values[1]) end
        sourceType = ExpandSourceType(Unescape(values[8]))
        category = ExpandCategory(Unescape(values[2]))
    end

    local effect = C.KnowledgeBase and C.KnowledgeBase:GetEffect(effectKey) or nil
    local provider = providerKey ~= "" and C.KnowledgeBase and C.KnowledgeBase:GetProvider(providerKey) or nil
    if sourceName == nil or sourceName == "" then
        sourceName = provider and tostring(provider.name or provider.displayName or providerKey) or providerKey
        if sourceName ~= "" and string.sub(sourceName, 1, 8) == "SCRIBED_" then
            sourceName = string.gsub(string.sub(sourceName, 9), "_", " ")
            sourceName = string.lower(sourceName):gsub("(%a)([%w']*)", function(a, b) return string.upper(a) .. b end)
        end
    end
    if sourceType == "" then sourceType = "NETWORK" end
    if not category or category == "" then
        category = effect and tostring(effect.category or effect.effectType or effect.type or "SUPPORT") or "SUPPORT"
    end

    return {
        key = effectKey, effectKey = effectKey, category = category,
        name = effect and effect.name or effectKey,
        confidence = partial and "LIKELY" or "CONFIRMED",
        providerKey = providerKey, responsibilityKeys = responsibilityKeys,
        normalized = providerKey ~= "" or #responsibilityKeys > 0,
        sources = { { type = sourceType, name = sourceName, providerKey = providerKey, confidence = partial and "LIKELY" or "CONFIRMED" } },
    }
end

function Network:BuildInterpretedFromPending(pending, partial)
    local interpreted, seen = {}, {}
    for index = 1, pending.chunkCount do
        local chunk = pending.chunks[index]
        if chunk == nil and not partial then return nil, "missing_chunk" end
        if chunk and chunk ~= "" then
            for _, encodedEntry in ipairs(Split(chunk, ENTRY_SEP)) do
                local capability = self:DecodeEntry(encodedEntry, partial)
                if capability then
                    local signature = table.concat({ capability.effectKey or "", capability.providerKey or "", tostring(capability.sources and capability.sources[1] and capability.sources[1].type or "") }, "|")
                    if not seen[signature] then
                        seen[signature] = true
                        interpreted[#interpreted + 1] = capability
                    end
                end
            end
        end
    end
    return interpreted
end

function Network:MergeWithExistingProfile(sender, interpreted)
    local merged, seen = {}, {}
    local existing = C.Database and C.Database.GetPlayer and C.Database:GetPlayer(sender) or nil
    local current = existing and existing.capabilities and existing.capabilities.interpreted or {}
    for _, capability in ipairs(current or {}) do
        local signature = table.concat({ tostring(capability.effectKey or capability.key or ""), tostring(capability.providerKey or (capability.sources and capability.sources[1] and capability.sources[1].providerKey) or "") }, "|")
        if not seen[signature] then seen[signature] = true; merged[#merged + 1] = capability end
    end
    for _, capability in ipairs(interpreted or {}) do
        local signature = table.concat({ tostring(capability.effectKey or capability.key or ""), tostring(capability.providerKey or "") }, "|")
        if not seen[signature] then seen[signature] = true; merged[#merged + 1] = capability end
    end
    return merged
end

function Network:CompleteProfile(sender, pending, partial)
    local interpreted, decodeError = self:BuildInterpretedFromPending(pending, partial)
    if not interpreted then return self:Reject(decodeError or "decode_failed") end

    -- Partial commits merge into the last known profile so missing chunks do not
    -- erase previously confirmed capabilities. A complete revision replaces it.
    if partial then interpreted = self:MergeWithExistingProfile(sender, interpreted) end

    local snapshot = {
        accountName = sender,
        characterName = pending.unitTag and zo_strformat("<<1>>", GetUnitName(pending.unitTag) or "") or "",
        classId = pending.classId, role = pending.role, unitTag = pending.unitTag,
        online = true, isLocalPlayer = false, conductorVersion = pending.version,
        protocolVersion = self.protocolVersion, networkState = partial and "PARTIAL" or "SYNCED", networkSeenAt = Now(),
        profileRevision = pending.revision, profileCompleteness = partial and "PARTIAL" or "COMPLETE",
        capabilities = { interpreted = interpreted, normalized = interpreted,
            scan = { networkProfile = true, normalizedProfile = true, schemaVersion = self.capabilitySchemaVersion, partial = partial == true, scannedAt = Now() } },
    }
    if C.RaidIntelligenceEngine and C.RaidIntelligenceEngine.BuildProfile then C.RaidIntelligenceEngine:BuildProfile(snapshot) end
    if C.Database then C.Database:UpdatePlayer(sender, snapshot, "network") end

    local key = string.lower(sender)
    local peer = self.peers[key]
    if peer then
        peer.profileState = partial and "PARTIAL" or "COMMITTED"
        peer.capabilityCount = #interpreted
        peer.committedRevision = pending.revision
        peer.profileCompleteness = partial and "PARTIAL" or "COMPLETE"
        peer.lastCommittedAt = Now()
    end
    self.stats.profileCommits = (self.stats.profileCommits or 0) + 1
    self.stats.normalizedEntriesReceived = (self.stats.normalizedEntriesReceived or 0) + #interpreted
    if partial then
        self.stats.partialProfilesCommitted = (self.stats.partialProfilesCommitted or 0) + 1
        if C.EventBus then C.EventBus:Publish("NETWORK_PROFILE_PARTIAL", { accountName = sender, snapshot = snapshot }) end
    else
        self.pending[key] = nil
        self.stats.profilesCompleted = (self.stats.profilesCompleted or 0) + 1
        self.stats.normalizedProfilesCompleted = (self.stats.normalizedProfilesCompleted or 0) + 1
        if C.EventBus then C.EventBus:Publish("NETWORK_PROFILE_COMPLETED", { accountName = sender, snapshot = snapshot }) end
    end
    return true
end

function Network:ResetForLiveSession(generation, fingerprint, reason)
    self.peers = {}
    self.pending = {}
    self.outboundQueue = {}
    self.outboundRetry = nil
    self.outboundSending = false
    self.revision = ((tonumber(self.revision) or 0) + 1) % 65535
    self.sendGeneration = (tonumber(self.sendGeneration) or 0) + 1
    self.lastSentSignature = nil
    self.liveSessionGeneration = tonumber(generation) or 0
    self.liveRosterFingerprint = tostring(fingerprint or "")
    if C.Diagnostics then
        C.Diagnostics:AddFields("NETWORK", "Network context reset", {
            generation = self.liveSessionGeneration,
            fingerprint = self.liveRosterFingerprint,
            reason = tostring(reason or "live session changed"),
        })
    end
    self:RefreshRosterPresence()
end

function Network:RefreshRosterPresence()
    local rosterCount = 0
    if IsUnitGrouped and IsUnitGrouped("player") then rosterCount = GetGroupSize and GetGroupSize() or 0
    elseif GetDisplayName then rosterCount = 1 end
    self.stats.rosterMembers = rosterCount
    local localName = GetDisplayName and GetDisplayName() or ""
    if localName ~= "" then
        self.peers[string.lower(localName)] = {
            accountName = localName, version = C.Platform.version, protocol = self.protocolVersion,
            compatibility = "COMPATIBLE", lastSeenAt = Now(), localPlayer = true, profileState = "LOCAL",
        }
    end
end

function Network:PruneStalePeers()
    local now, roster = Now(), {}
    if IsUnitGrouped and IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            local name = tag and GetUnitDisplayName(tag)
            if name and name ~= "" then roster[string.lower(name)] = true end
        end
    else
        local name = GetDisplayName and GetDisplayName() or ""
        if name ~= "" then roster[string.lower(name)] = true end
    end
    for key, peer in pairs(self.peers) do
        if not roster[key] then self.peers[key] = nil end
    end
    for key, pending in pairs(self.pending) do
        if now - (pending.lastChunkAt or pending.startedAt or now) > PENDING_TIMEOUT_MS then
            self.pending[key] = nil
            self.stats.timedOutProfiles = (self.stats.timedOutProfiles or 0) + 1
            self.rejectReasons.timeout = (self.rejectReasons.timeout or 0) + 1
        end
    end
end

function Network:GetConnectedPlayers()
    local out = {}
    for _, peer in pairs(self.peers) do out[#out + 1] = peer end
    table.sort(out, function(a,b) return tostring(a.accountName) < tostring(b.accountName) end)
    return out
end

function Network:GetDiagnostics()
    local transport = C.NetworkTransport and C.NetworkTransport:GetStatus() or { available=false, ready=false, name="none" }
    local players, peerNames, rejectReasons = self:GetConnectedPlayers(), {}, {}
    for _, peer in ipairs(players) do
        peerNames[#peerNames + 1] = string.format("%s [%s; %s; %d/%d]", tostring(peer.accountName or "unknown"),
            peer.localPlayer and "LOCAL" or tostring(peer.compatibility or "SEEN"), tostring(peer.profileState or "SEEN"),
            tonumber(peer.chunksReceived) or 0, tonumber(peer.chunksExpected) or 0)
    end
    for reason, count in pairs(self.rejectReasons or {}) do rejectReasons[#rejectReasons + 1] = string.format("%s: %d", reason, count) end
    table.sort(rejectReasons)
    return {
        enabled = self.enabled, protocolVersion = self.protocolVersion, addonVersion = C.Platform.version,
        transport = transport.name, transportAvailable = transport.available, dedicatedPayloadReady = transport.ready,
        transportReason = transport.reason, protocolId = transport.protocolId,
        connectedPlayers = #players, sent = self.stats.sent, received = self.stats.received,
        rejected = self.stats.rejected, profilesCompleted = self.stats.profilesCompleted,
        profileChangesSent = self.stats.profileChangesSent, profileSendsSuppressed = self.stats.profileSendsSuppressed,
        normalizedProfilesCompleted = self.stats.normalizedProfilesCompleted,
        normalizedEntriesSent = self.stats.normalizedEntriesSent, normalizedEntriesReceived = self.stats.normalizedEntriesReceived,
        duplicatePackets = self.stats.duplicatePackets, stalePackets = self.stats.stalePackets,
        timedOutProfiles = self.stats.timedOutProfiles, queuedChunks = self.stats.queuedChunks,
        partialProfilesCommitted = self.stats.partialProfilesCommitted or 0, profileCommits = self.stats.profileCommits or 0,
        retryPacketsSent = self.stats.retryPacketsSent or 0,
        capabilitySchemaVersion = self.capabilitySchemaVersion or 2, lastSyncAt = self.stats.lastSyncAt,
        rosterMembers = self.stats.rosterMembers or 0, transportInitAttempts = self.stats.transportInitAttempts or 0,
        transportRecoveries = self.stats.transportRecoveries or 0, lastTransportAttemptAt = self.stats.lastTransportAttemptAt or 0,
        lastSendAt = self.stats.lastSendAt or 0, lastReceiveAt = self.stats.lastReceiveAt or 0,
        lastSendError = self.lastSendError or transport.lastSendError, transportLastError = transport.lastError,
        transportLastStep = transport.lastStep, transportInitLibraryAttempts = transport.initAttempts,
        transportSendAttempts = transport.sendAttempts, transportReceiveCallbacks = transport.receiveCallbacks,
        registrationMode = transport.registrationMode, finalizeMode = transport.finalizeMode,
        sendMode = transport.sendMode, peerNames = peerNames, rejectReasons = rejectReasons,
        lastRejectReason = self.lastRejectReason,
        discoveryReady = self.discoveryProtocol ~= nil,
        discoveryError = self.discoveryError,
        lastDiscoverySentAt = self.lastDiscoverySentAt or 0,
    }
end

function Network:Initialize()
    if self.initialized then return true end
    self.stats.startedAt = Now()
    self:EnsureTransportReady(true)

    if C.EventBus then
        C.EventBus:Subscribe("LOCAL_CAPABILITIES_CHANGED", self, function(data)
            self:ScheduleSnapshot(data and data.snapshot or (C.PlayerScanner and C.PlayerScanner:GetLastLocalSnapshot()), data and data.forced, "capability_change")
        end)
        C.EventBus:Subscribe("GROUP_SCANNED", self, function() self:RefreshRosterPresence() end)
    end

    EVENT_MANAGER:RegisterForEvent("ConductorNetworkGroupUpdate", EVENT_GROUP_UPDATE, function()
        self:RefreshRosterPresence()
        self:PruneStalePeers()
        self:EnsureTransportReady(false)
        self:BroadcastDiscovery()
        -- PlayerScanner publishes a profile only when normalized capabilities change.
    end)
    EVENT_MANAGER:RegisterForEvent("ConductorNetworkActivated", EVENT_PLAYER_ACTIVATED, function()
        self:RefreshRosterPresence()
        self:EnsureTransportReady(false)
        self:BroadcastDiscovery()
        -- The settled post-zone scanner refresh owns capability publication.
    end)

    -- Discovery is intentionally independent from capability and Raid Plan traffic.
    -- It never pauses during a share and uses replacement semantics so only the
    -- newest presence advertisement can remain queued.
    EVENT_MANAGER:RegisterForUpdate("ConductorNetworkDiscovery", self.discoveryIntervalMs, function()
        if not SRC.saved or SRC.saved.enabled ~= true then return end
        if not self.transportReady then self:EnsureTransportReady(false) end
        self:BroadcastDiscovery()
    end)

    EVENT_MANAGER:RegisterForUpdate("ConductorNetworkMaintenance", 15000, function()
        if not SRC.saved or SRC.saved.enabled ~= true then return end
        self:PruneStalePeers()
        if not self.transportReady then self:EnsureTransportReady(false) end
    end)

    self:RefreshRosterPresence()
    self:BroadcastDiscovery()
    zo_callLater(function()
        self:EnsureTransportReady(false)
        local snapshot = C.PlayerScanner and C.PlayerScanner:ScanLocalPlayer(false)
        if snapshot then self:QueueSnapshot(snapshot, true) end
    end, 1500)
    self.initialized = true
    return true
end
