local C = Conductor
C.SessionTransfer = C.SessionTransfer or {}
local Transfer = C.SessionTransfer

-- Development IDs. Reserve these in the LibGroupBroadcast registry before public release.
Transfer.PROTOCOL = {
    DATA = { id=232, name="CONDUCTOR_SESSION_DATA_DEV" },
    HEADER = { id=233, name="CONDUCTOR_SESSION_HEADER_DEV" },
    RESPONSE = { id=234, name="CONDUCTOR_SESSION_RESPONSE_DEV" },
    CONTROL = { id=235, name="CONDUCTOR_SESSION_CONTROL_DEV" },
}
Transfer.CHUNK_BYTES = 21
Transfer.MAX_CHUNKS = 4095
Transfer.INCOMING_TIMEOUT_MS = 90000
Transfer.OUTGOING_TIMEOUT_MS = 180000
Transfer.MAX_OUTGOING_TIMEOUT_MS = 900000
Transfer.TRANSPORT_OWNER = "RAID_PLAN"
Transfer.RETRY_DELAY_MS = 350
Transfer.MAX_QUEUE_RETRIES = 40
Transfer.PHASE = { START=1, COMPLETE=2 }
Transfer.STATUS = { ACCEPTED=1, DECLINED=2, INVALID=3, INCOMPATIBLE=4, IMPORT_FAILED=5 }
Transfer.STATUS_NAME = { [1]="accepted", [2]="declined", [3]="invalid", [4]="incompatible", [5]="import failed" }
Transfer.COMMAND = { CANCEL=1, CLOSE=2 }

local function Now()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end

local function SenderAccount(unitTag)
    local raw = tostring(unitTag or "")
    if raw:sub(1, 1) == "@" then return Normalize(raw) end
    if GetUnitDisplayName then return Normalize(GetUnitDisplayName(raw) or "") end
    return ""
end

local function IsSelf(unitTag)
    if AreUnitsEqual then return AreUnitsEqual("player", unitTag) end
    return SenderAccount(unitTag) == Normalize(GetDisplayName and GetDisplayName() or "")
end

local function Alert(message)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage(message) elseif d then d(message) end
    if ZO_Alert then pcall(ZO_Alert, UI_ALERT_CATEGORY_ALERT, nil, message) end
end

local function ProtocolEnabled(protocol)
    return protocol and (not protocol.IsEnabled or protocol:IsEnabled())
end

local function ReleaseTransport()
    if C.NetworkTransport then C.NetworkTransport:ReleaseExclusive(Transfer.TRANSPORT_OWNER) end
    if C.Network then C.Network:ResumeAfterSessionTransfer() end
end

local function SendProtocol(protocol, values)
    if not protocol or not ProtocolEnabled(protocol) then return false end
    -- Dedicated SessionTransfer protocols use LibGroupBroadcast directly, but
    -- all other Conductor producers are paused by the exclusive lease.
    return protocol:Send(values) == true
end

function Transfer:GenerateToken()
    local base = Now() % 16777215
    local random = math.random and math.random(1, 65535) or 1
    return (base + random) % 16777215
end

function Transfer:DeclareProtocols()
    local LGB = LibGroupBroadcast
    local handler = C.NetworkTransport and C.NetworkTransport.handler
    if not LGB or not handler then return false, "Conductor's LibGroupBroadcast handler is unavailable." end

    local header = handler:DeclareProtocol(self.PROTOCOL.HEADER.id, self.PROTOCOL.HEADER.name)
    header:AddField(LGB.CreateNumericField("token", { numBits=24, trimValues=true }))
    header:AddField(LGB.CreateEnumField("phase", { self.PHASE.START, self.PHASE.COMPLETE }))
    header:AddField(LGB.CreateNumericField("chunkCount", { numBits=12, trimValues=true }))
    header:AddField(LGB.CreateNumericField("byteLength", { numBits=17, trimValues=true }))
    header:AddField(LGB.CreateNumericField("checksum", { numBits=32, trimValues=true }))
    header:AddField(LGB.CreateNumericField("schema", { numBits=8, trimValues=true }))
    header:AddField(LGB.CreateNumericField("revision", { numBits=16, trimValues=true }))
    header:AddField(LGB.CreateStringField("sessionId", { minLength=1, maxLength=64 }))
    header:OnData(function(unitTag, values) self:OnHeader(unitTag, values) end)
    header:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=false })

    local data = handler:DeclareProtocol(self.PROTOCOL.DATA.id, self.PROTOCOL.DATA.name)
    data:AddField(LGB.CreateNumericField("token", { numBits=24, trimValues=true }))
    data:AddField(LGB.CreateNumericField("position", { numBits=12, trimValues=true }))
    data:AddField(LGB.CreateStringField("data", { minLength=0, maxLength=self.CHUNK_BYTES }))
    data:OnData(function(unitTag, values) self:OnData(unitTag, values) end)
    data:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=false })

    local response = handler:DeclareProtocol(self.PROTOCOL.RESPONSE.id, self.PROTOCOL.RESPONSE.name)
    response:AddField(LGB.CreateNumericField("token", { numBits=24, trimValues=true }))
    response:AddField(LGB.CreateEnumField("status", { self.STATUS.ACCEPTED, self.STATUS.DECLINED, self.STATUS.INVALID, self.STATUS.INCOMPATIBLE, self.STATUS.IMPORT_FAILED }))
    response:AddField(LGB.CreateStringField("host", { minLength=1, maxLength=40 }))
    response:AddField(LGB.CreateStringField("version", { minLength=1, maxLength=24 }))
    response:AddField(LGB.CreateNumericField("schema", { numBits=8, trimValues=true }))
    response:OnData(function(unitTag, values) self:OnResponse(unitTag, values) end)
    response:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=false })

    local control = handler:DeclareProtocol(self.PROTOCOL.CONTROL.id, self.PROTOCOL.CONTROL.name)
    control:AddField(LGB.CreateNumericField("token", { numBits=24, trimValues=true }))
    control:AddField(LGB.CreateEnumField("command", { self.COMMAND.CANCEL, self.COMMAND.CLOSE }))
    control:AddField(LGB.CreateStringField("host", { minLength=1, maxLength=40 }))
    control:OnData(function(unitTag, values) self:OnControl(unitTag, values) end)
    control:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=false })

    self.protocols = { header=header, data=data, response=response, control=control }
    return true
end

function Transfer:Initialize()
    if C.NetworkTransport then C.NetworkTransport:ReleaseExclusive(self.TRANSPORT_OWNER) end
    self.incoming = {}
    self.outgoing = nil
    self.pendingValidated = nil
    self.responses = {}
    local ok, errorMessage = pcall(function()
        local declared, reason = self:DeclareProtocols()
        if not declared then error(reason) end
    end)
    if not ok then
        self.ready = false
        self.reason = tostring(errorMessage)
        if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail(self.reason) end
        return false
    end
    self.ready = true
    self.reason = "sharing protocols ready"
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate("ConductorSessionTransferMaintenance", 2000, function() self:MaintenanceTick() end)
    end
    return true
end

function Transfer:CanStart()
    if not self.ready then return false, self.reason or "Session transfer is unavailable." end
    if self.outgoing and self.outgoing.state == "SENT" and Now() - (self.outgoing.completedAt or 0) > 5000 then
        self.lastOutgoing = self.outgoing
        self.outgoing = nil
    end
    if self.outgoing then return false, "A Raid Plan transfer is already in progress." end
    if IsUnitInCombat and IsUnitInCombat("player") then return false, "Raid Plans can only be shared outside combat." end
    if not IsUnitGrouped or not IsUnitGrouped("player") then return false, "You must be in a group to share a Raid Plan." end
    for name, protocol in pairs(self.protocols or {}) do
        if not ProtocolEnabled(protocol) then return false, "The Conductor " .. name .. " protocol is disabled in LibGroupBroadcast settings." end
    end
    return true
end

function Transfer:Start(snapshot, serialized)
    local canStart, reason = self:CanStart()
    if not canStart then return false, reason end
    local length = #serialized
    local count = math.ceil(length / self.CHUNK_BYTES)
    if count < 1 then count = 1 end
    if count > self.MAX_CHUNKS then return false, "The Raid Plan is too large to share." end

    local acquired, acquireError = C.NetworkTransport and C.NetworkTransport:AcquireExclusive(self.TRANSPORT_OWNER)
    if not acquired then return false, acquireError or "Conductor network transport is busy." end
    if C.Network then C.Network:SuspendForSessionTransfer() end

    local token = self:GenerateToken()
    local chunks = {}
    for position = 1, count do
        chunks[position] = string.sub(serialized, ((position - 1) * self.CHUNK_BYTES) + 1, position * self.CHUNK_BYTES)
    end
    self.outgoing = {
        token=token, snapshot=snapshot, serialized=serialized, chunks=chunks, count=count,
        nextPosition=1, startedAt=Now(), checksum=C.RaidPlanSerializer:Checksum(serialized),
        state="SENDING", responses={}, queueRetries=0, retryAt=0, pendingKind="HEADER_START",
        timeoutMs=math.min(self.MAX_OUTGOING_TIMEOUT_MS, math.max(self.OUTGOING_TIMEOUT_MS, (count * 3000) + 60000)),
    }
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Reset(); C.SessionShareDiagnostics:Update({
        transferId=token, direction="OUTGOING", host=snapshot.hostAccount, team=snapshot.teamName,
        state="SENDING", chunksExpected=count, chunksReceived=0, bytesExpected=length,
        bytesReceived=0, checksum=self.outgoing.checksum, startedAt=self.outgoing.startedAt,
    }) end

    local sent = SendProtocol(self.protocols.header, {
        token=token, phase=self.PHASE.START, chunkCount=count, byteLength=length,
        checksum=self.outgoing.checksum, schema=snapshot.snapshotSchemaVersion,
        revision=snapshot.sessionRevision, sessionId=snapshot.sessionId,
    })
    if not sent then
        self.outgoing.retryAt = Now() + self.RETRY_DELAY_MS
        self.outgoing.queueRetries = 1
        return true, token
    end
    self.outgoing.pendingKind = nil
    self:SendNextChunk()
    return true, token
end

function Transfer:SendNextChunk()
    local outgoing = self.outgoing
    if not outgoing or outgoing.state ~= "SENDING" then return false end
    local position = outgoing.nextPosition
    local sent
    if position > outgoing.count then
        outgoing.pendingKind = "HEADER_COMPLETE"
        sent = SendProtocol(self.protocols.header, {
            token=outgoing.token, phase=self.PHASE.COMPLETE, chunkCount=outgoing.count,
            byteLength=#outgoing.serialized, checksum=outgoing.checksum,
            schema=outgoing.snapshot.snapshotSchemaVersion, revision=outgoing.snapshot.sessionRevision,
            sessionId=outgoing.snapshot.sessionId,
        })
        if sent then outgoing.state = "COMPLETING"; outgoing.pendingKind=nil end
    else
        outgoing.pendingKind = "DATA"
        sent = SendProtocol(self.protocols.data, { token=outgoing.token, position=position, data=outgoing.chunks[position] })
        if sent then outgoing.nextPosition = position + 1; outgoing.pendingKind=nil end
    end
    if not sent then
        outgoing.queueRetries = (outgoing.queueRetries or 0) + 1
        outgoing.retryAt = Now() + self.RETRY_DELAY_MS
    else
        outgoing.queueRetries = 0
        outgoing.retryAt = 0
    end
    return sent
end

function Transfer:GetIncoming(sender, token)
    return self.incoming[string.lower(Normalize(sender) .. "|" .. tostring(token))]
end

function Transfer:SetIncoming(sender, token, value)
    self.incoming[string.lower(Normalize(sender) .. "|" .. tostring(token))] = value
end

function Transfer:OnHeader(unitTag, values)
    local sender = SenderAccount(unitTag)
    local token = tonumber(values.token) or 0
    if token <= 0 or sender == "" then return end
    if IsSelf(unitTag) then
        local outgoing = self.outgoing
        if not outgoing or outgoing.token ~= token then return end
        if values.phase == self.PHASE.COMPLETE then
            outgoing.state = "SENT"
            outgoing.completedAt = Now()
            if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ state="SENT", completedAt=outgoing.completedAt, chunksReceived=outgoing.count, bytesReceived=#outgoing.serialized }) end
            Alert(string.format("|c55FF55Conductor finished sending %s.|r", tostring(outgoing.snapshot.teamName or "Raid Plan")))
            if C.EventBus then C.EventBus:Publish("RAID_PLAN_SHARED", { snapshot=outgoing.snapshot, transferId=token }) end
            ReleaseTransport()
        end
        return
    end

    if values.phase == self.PHASE.START then
        local incoming = {
            token=token, sender=sender, count=tonumber(values.chunkCount) or 0,
            byteLength=tonumber(values.byteLength) or 0, checksum=tonumber(values.checksum) or 0,
            schema=tonumber(values.schema) or 0, revision=tonumber(values.revision) or 0,
            sessionId=tostring(values.sessionId or ""), chunks={}, received=0,
            startedAt=Now(), lastAt=Now(), state="RECEIVING",
        }
        self:SetIncoming(sender, token, incoming)
        if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Reset(); C.SessionShareDiagnostics:Update({
            transferId=token, direction="INCOMING", host=sender, state="RECEIVING",
            chunksExpected=incoming.count, chunksReceived=0, bytesExpected=incoming.byteLength,
            bytesReceived=0, checksum=incoming.checksum, startedAt=incoming.startedAt,
        }) end
        return
    end

    local incoming = self:GetIncoming(sender, token)
    if not incoming then self:SendResponse(token, sender, self.STATUS.INVALID); return end
    incoming.lastAt = Now()
    if incoming.count ~= tonumber(values.chunkCount) or incoming.byteLength ~= tonumber(values.byteLength)
        or incoming.checksum ~= tonumber(values.checksum) or incoming.sessionId ~= tostring(values.sessionId or "") then
        self:RejectIncoming(incoming, "Transfer completion metadata did not match its start header.", self.STATUS.INVALID)
        return
    end
    self:FinalizeIncoming(incoming)
end

function Transfer:OnData(unitTag, values)
    local token = tonumber(values.token) or 0
    local position = tonumber(values.position) or 0
    if IsSelf(unitTag) then
        local outgoing = self.outgoing
        if not outgoing or outgoing.token ~= token then return end
        if position > 0 then
            if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ chunksReceived=position, bytesReceived=math.min(position * self.CHUNK_BYTES, #outgoing.serialized) }) end
            -- A full LibGroupBroadcast queue is transient. Keep the transfer
            -- alive and let MaintenanceTick retry instead of aborting the share.
            self:SendNextChunk()
        end
        return
    end

    local sender = SenderAccount(unitTag)
    local incoming = self:GetIncoming(sender, token)
    if not incoming or position < 1 or position > incoming.count then return end
    incoming.lastAt = Now()
    if incoming.chunks[position] == nil then
        incoming.chunks[position] = tostring(values.data or "")
        incoming.received = incoming.received + 1
        if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ chunksReceived=incoming.received, bytesReceived=math.min(incoming.received * self.CHUNK_BYTES, incoming.byteLength) }) end
    end
end

function Transfer:FinalizeIncoming(incoming)
    if incoming.received ~= incoming.count then
        self:RejectIncoming(incoming, string.format("Transfer was incomplete: %d of %d chunks arrived.", incoming.received, incoming.count), self.STATUS.INVALID)
        return
    end
    local parts = {}
    for position = 1, incoming.count do
        if incoming.chunks[position] == nil then self:RejectIncoming(incoming, "Transfer is missing a data chunk.", self.STATUS.INVALID); return end
        parts[position] = incoming.chunks[position]
    end
    local serialized = table.concat(parts)
    if #serialized ~= incoming.byteLength then self:RejectIncoming(incoming, "Transfer byte length did not match.", self.STATUS.INVALID); return end
    if C.RaidPlanSerializer:Checksum(serialized) ~= incoming.checksum then self:RejectIncoming(incoming, "Transfer checksum did not match.", self.STATUS.INVALID); return end
    local snapshot, decodeError = C.RaidPlanSerializer:Decode(serialized)
    if not snapshot then self:RejectIncoming(incoming, decodeError, self.STATUS.INVALID); return end
    if tonumber(snapshot.snapshotSchemaVersion) ~= C.RaidPlan.SCHEMA_VERSION then self:RejectIncoming(incoming, "This shared setup uses an incompatible schema.", self.STATUS.INCOMPATIBLE); return end
    local valid, validationError = C.RaidPlan:Validate(snapshot, false)
    if not valid then self:RejectIncoming(incoming, validationError, self.STATUS.INVALID); return end
    if Normalize(snapshot.hostAccount) ~= incoming.sender or tostring(snapshot.sessionId) ~= incoming.sessionId then
        self:RejectIncoming(incoming, "Shared setup identity did not match its sender.", self.STATUS.INVALID); return
    end
    local localAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    if not C.RaidPlan:ContainsPlayer(snapshot, localAccount) then
        self:RejectIncoming(incoming, "Your account is not included in this Raid Plan roster.", self.STATUS.INVALID, true); return
    end

    incoming.state = "VALIDATED"
    incoming.snapshot = snapshot
    incoming.serialized = serialized
    self.pendingValidated = incoming
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ state="VALIDATED", team=snapshot.teamName, validation="PASS", completedAt=Now() }) end
    if C.EventBus then C.EventBus:Publish("RAID_PLAN_TRANSFER_VALIDATED", { sender=incoming.sender, snapshot=snapshot, transferId=incoming.token }) end
    local shown = C.SessionDialogs and C.SessionDialogs:Show({ sender=incoming.sender, snapshot=snapshot, token=incoming.token })
    Alert(string.format("|cFFD447Conductor received and validated %s from %s.|r", tostring(snapshot.teamName or "a Raid Plan"), incoming.sender))
    if not shown then Alert("Open Raid Setup to accept or decline the shared Raid Plan.") end
end

function Transfer:RejectIncoming(incoming, reason, status, quiet)
    incoming.state = "FAILED"
    incoming.failureReason = tostring(reason or "validation failed")
    self:SetIncoming(incoming.sender, incoming.token, nil)
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail(incoming.failureReason) end
    self:SendResponse(incoming.token, incoming.sender, status or self.STATUS.INVALID)
    if not quiet then Alert("|cFF5555Conductor rejected a shared Raid Plan:|r " .. incoming.failureReason) end
end

function Transfer:SendResponse(token, host, status)
    if not self.ready or not ProtocolEnabled(self.protocols.response) then return false end
    return SendProtocol(self.protocols.response, {
        token=tonumber(token) or 0, status=status, host=Normalize(host),
        version=tostring(SupportRotationCallouts.version or "unknown"), schema=C.RaidPlan.SCHEMA_VERSION,
    })
end

function Transfer:OnResponse(unitTag, values)
    if IsSelf(unitTag) then return end
    local outgoing = self.outgoing
    local sender = SenderAccount(unitTag)
    if not outgoing or outgoing.token ~= tonumber(values.token) then return end
    local localAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    if Normalize(values.host) ~= localAccount then return end
    local status = tonumber(values.status) or 0
    outgoing.responses[sender] = { status=status, statusName=self.STATUS_NAME[status] or "unknown", version=values.version, schema=values.schema, at=Now() }
    if C.RaidSession then
        local sessionState = status == self.STATUS.ACCEPTED and "accepted" or status == self.STATUS.DECLINED and "declined" or "incompatible"
        C.RaidSession:SetSynchronizationState(sender, sessionState, "shared Raid Plan response")
    end
    Alert(string.format("|c%s%s %s the shared team.|r", status == self.STATUS.ACCEPTED and "55FF55" or "FFD447", sender, self.STATUS_NAME[status] or "responded to"))
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_TRANSFER_RESPONSE", { accountName=sender, status=status, transferId=outgoing.token }) end
end

function Transfer:SendControl(command)
    local outgoing = self.outgoing
    local token = outgoing and outgoing.token or 0
    return SendProtocol(self.protocols.control, { token=token, command=command, host=Normalize(GetDisplayName and GetDisplayName() or "") })
end

function Transfer:OnControl(unitTag, values)
    if IsSelf(unitTag) then return end
    local sender = SenderAccount(unitTag)
    if sender ~= Normalize(values.host) then return end
    local incoming = self:GetIncoming(sender, tonumber(values.token) or 0)
    if values.command == self.COMMAND.CANCEL and incoming then
        self:SetIncoming(sender, incoming.token, nil)
        if self.pendingValidated == incoming then self.pendingValidated = nil end
        Alert("|cFFD447The host cancelled the Conductor team transfer.|r")
    elseif values.command == self.COMMAND.CLOSE then
        local session = C.RaidSession and C.RaidSession:GetActive()
        if session and Normalize(session.hostAccount) == sender then
            C.RaidSession:Archive("host closed shared Raid Plan")
            Alert("|cFFD447The host closed the shared Conductor Raid Plan.|r")
        end
    end
end

function Transfer:CancelOutgoing()
    if not self.outgoing then return false end
    self:SendControl(self.COMMAND.CANCEL)
    self.outgoing = nil
    ReleaseTransport()
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ state="CANCELLED", completedAt=Now() }) end
    return true
end

function Transfer:MaintenanceTick()
    local now = Now()
    local outgoing = self.outgoing
    if outgoing and outgoing.state == "SENDING" and (outgoing.retryAt or 0) > 0 and now >= outgoing.retryAt then
        if (outgoing.queueRetries or 0) > self.MAX_QUEUE_RETRIES then
            if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail("LibGroupBroadcast queue remained unavailable.") end
            Alert("|cFF5555Conductor could not queue the Raid Plan. Try again after group traffic settles.|r")
            self.outgoing = nil
            ReleaseTransport()
        elseif outgoing.pendingKind == "HEADER_START" then
            local sent = SendProtocol(self.protocols.header, {
                token=outgoing.token, phase=self.PHASE.START, chunkCount=outgoing.count, byteLength=#outgoing.serialized,
                checksum=outgoing.checksum, schema=outgoing.snapshot.snapshotSchemaVersion,
                revision=outgoing.snapshot.sessionRevision, sessionId=outgoing.snapshot.sessionId,
            })
            if sent then outgoing.pendingKind=nil; outgoing.retryAt=0; outgoing.queueRetries=0; self:SendNextChunk()
            else outgoing.queueRetries=(outgoing.queueRetries or 0)+1; outgoing.retryAt=now+self.RETRY_DELAY_MS end
        else
            self:SendNextChunk()
        end
    end
    for key, incoming in pairs(self.incoming) do
        if now - (incoming.lastAt or incoming.startedAt or now) > self.INCOMING_TIMEOUT_MS then
            self.incoming[key] = nil
            if self.pendingValidated == incoming then self.pendingValidated = nil end
            if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail("Incoming transfer timed out.") end
        end
    end
    if self.outgoing and self.outgoing.state ~= "SENT" and now - self.outgoing.startedAt > (self.outgoing.timeoutMs or self.OUTGOING_TIMEOUT_MS) then
        if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail("Outgoing transfer timed out.") end
        self.outgoing = nil
        ReleaseTransport()
    end
end

function Transfer:GetStatus()
    return {
        ready=self.ready == true, reason=self.reason, outgoing=self.outgoing,
        pendingValidated=self.pendingValidated, responses=self.outgoing and self.outgoing.responses or {},
    }
end
