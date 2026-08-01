local C = Conductor
C.NetworkTransport = C.NetworkTransport or {}
local Transport = C.NetworkTransport

-- Development protocol ID. This must be formally reserved with the
-- LibGroupBroadcast registry before a public release.
Transport.PROTOCOL_ID = 231
Transport.PROTOCOL_NAME = "CONDUCTOR_PROFILE_V3_DEV"
Transport.MAX_PAYLOAD = 190

local function Now()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Method(object, name)
    local fn = object and object[name]
    return type(fn) == "function" and fn or nil
end

local function Try(label, fn)
    local ok, result = pcall(fn)
    if ok then return true, result end
    return false, tostring(result)
end

function Transport:ResetAttemptState()
    self.lastError = nil
    self.lastStep = "starting"
    self.registrationMode = "none"
    self.finalizeMode = "none"
    self.sendMode = "none"
end

function Transport:Initialize(onPayload, force)
    self.available = LibGroupBroadcast ~= nil
    self.name = self.available and "LibGroupBroadcast" or "none"
    self.onPayload = onPayload or self.onPayload
    self.initAttempts = (self.initAttempts or 0) + 1
    self.lastInitAt = Now()

    if self.ready and self.protocol and not force then
        self.reason = "protocol ready"
        return true
    end

    self.ready = false
    self.handler = nil
    self.protocol = nil
    self:ResetAttemptState()

    if not self.available then
        self.reason = "LibGroupBroadcast unavailable"
        self.lastStep = "library missing"
        return false
    end

    local lib = LibGroupBroadcast
    local register = Method(lib, "RegisterHandler")
    if not register then
        self.reason = "RegisterHandler API unavailable"
        self.lastError = self.reason
        self.lastStep = "register handler"
        return false
    end

    self.lastStep = "register handler"
    local ok, handler = Try("handler-two-args", function()
        return register(lib, "Conductor", "Conductor")
    end)
    if ok and handler then
        self.registrationMode = "RegisterHandler(name, namespace)"
    else
        local firstError = handler
        ok, handler = Try("handler-one-arg", function()
            return register(lib, "Conductor")
        end)
        if ok and handler then
            self.registrationMode = "RegisterHandler(name)"
        else
            self.reason = "handler registration failed"
            self.lastError = tostring(handler or firstError or "unknown error")
            return false
        end
    end

    local registeredHandler = handler
    if Method(registeredHandler, "SetDisplayName") then pcall(registeredHandler.SetDisplayName, registeredHandler, "Conductor") end
    if Method(registeredHandler, "SetDescription") then pcall(registeredHandler.SetDescription, registeredHandler, "Shares Conductor capability profiles with grouped Conductor users.") end

    self.lastStep = "declare protocol"
    local declare = Method(registeredHandler, "DeclareProtocol")
    if not declare then
        self.reason = "DeclareProtocol API unavailable"
        self.lastError = self.reason
        return false
    end

    local protocol
    ok, protocol = Try("protocol-two-args", function()
        return declare(registeredHandler, self.PROTOCOL_ID, self.PROTOCOL_NAME)
    end)
    if not ok or not protocol then
        local firstError = protocol
        ok, protocol = Try("protocol-one-arg", function()
            return declare(registeredHandler, self.PROTOCOL_ID)
        end)
        if not ok or not protocol then
            self.reason = "protocol declaration failed"
            self.lastError = tostring(protocol or firstError or "unknown error")
            return false
        end
    end

    if Method(protocol, "SetDisplayName") then pcall(protocol.SetDisplayName, protocol, "Conductor Capability Profile") end
    if Method(protocol, "SetDescription") then pcall(protocol.SetDescription, protocol, "Compact, change-based capability synchronization for Conductor group coverage.") end

    self.lastStep = "add payload field"
    local createStringField = lib.CreateStringField
    local addField = Method(protocol, "AddField")
    if type(createStringField) ~= "function" or not addField then
        self.reason = "string field API unavailable"
        self.lastError = self.reason
        return false
    end

    local field
    ok, field = Try("string-field-options", function()
        return createStringField("payload", { maxLength = self.MAX_PAYLOAD })
    end)
    if not ok or not field then
        local firstError = field
        ok, field = Try("string-field-length", function()
            return createStringField("payload", self.MAX_PAYLOAD)
        end)
        if not ok or not field then
            self.reason = "payload field creation failed"
            self.lastError = tostring(field or firstError or "unknown error")
            return false
        end
    end

    ok, field = Try("add-field", function()
        return addField(protocol, field)
    end)
    if not ok then
        self.reason = "payload field registration failed"
        self.lastError = tostring(field)
        return false
    end

    self.lastStep = "register receive callback"
    local onData = Method(protocol, "OnData")
    if not onData then
        self.reason = "OnData API unavailable"
        self.lastError = self.reason
        return false
    end
    ok, handler = Try("on-data", function()
        return onData(protocol, function(first, second)
            -- LibGroupBroadcast versions differ on callback argument order.
            -- Resolve the payload table and sender defensively instead of
            -- rejecting valid traffic when the order is reversed.
            local unitTag, values
            if type(first) == "table" then
                values, unitTag = first, second
            else
                unitTag, values = first, second
            end
            self.lastReceiveAt = Now()
            self.receiveCallbacks = (self.receiveCallbacks or 0) + 1
            if self.onPayload then
                self.onPayload(unitTag, type(values) == "table" and values.payload or "")
            end
        end)
    end)
    if not ok then
        self.reason = "receive callback registration failed"
        self.lastError = tostring(handler)
        return false
    end

    self.lastStep = "finalize protocol"
    local finalize = Method(protocol, "Finalize")
    if not finalize then
        self.reason = "Finalize API unavailable"
        self.lastError = self.reason
        return false
    end

    local finalized
    ok, finalized = Try("finalize-options", function()
        return finalize(protocol, { isRelevantInCombat = false, replaceQueuedMessages = false })
    end)
    if ok and finalized ~= false then
        self.finalizeMode = "Finalize(options)"
    else
        local firstError = finalized
        ok, finalized = Try("finalize-no-args", function()
            return finalize(protocol)
        end)
        if ok and finalized ~= false then
            self.finalizeMode = "Finalize()"
        else
            self.reason = "protocol finalization failed"
            self.lastError = tostring(finalized or firstError or "Finalize returned false")
            return false
        end
    end

    self.handler = registeredHandler
    self.protocol = protocol
    self.ready = true
    self.reason = "protocol ready"
    self.lastStep = "ready"
    self.readyAt = Now()
    return true
end

function Transport:Send(payload)
    self.sendAttempts = (self.sendAttempts or 0) + 1
    self.lastSendAttemptAt = Now()
    if not self.ready or not self.protocol then
        self.lastSendError = "transport not ready"
        return false, self.lastSendError
    end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then
        self.lastSendError = "protocol disabled in LibGroupBroadcast settings"
        return false, self.lastSendError
    end

    local send = Method(self.protocol, "Send")
    if not send then
        self.lastSendError = "Send API unavailable"
        return false, self.lastSendError
    end

    local ok, result = Try("send-options", function()
        return send(self.protocol, { payload = tostring(payload or "") }, { replaceQueuedMessages = false })
    end)
    if ok and result ~= false then
        self.sendMode = "Send(values, options)"
        self.lastSendAt = Now()
        self.lastSendError = nil
        return true
    end

    local firstError = result
    ok, result = Try("send-no-options", function()
        return send(self.protocol, { payload = tostring(payload or "") })
    end)
    if ok and result ~= false then
        self.sendMode = "Send(values)"
        self.lastSendAt = Now()
        self.lastSendError = nil
        return true
    end

    self.lastSendError = tostring(result or firstError or "message was not queued")
    self.lastError = self.lastSendError
    return false, self.lastSendError
end

function Transport:GetStatus()
    return {
        available = self.available == true,
        ready = self.ready == true,
        name = self.name or "none",
        reason = self.reason or "not initialized",
        lastError = self.lastError,
        lastSendError = self.lastSendError,
        lastStep = self.lastStep,
        protocolId = self.PROTOCOL_ID,
        protocolName = self.PROTOCOL_NAME,
        initAttempts = self.initAttempts or 0,
        sendAttempts = self.sendAttempts or 0,
        receiveCallbacks = self.receiveCallbacks or 0,
        registrationMode = self.registrationMode or "none",
        finalizeMode = self.finalizeMode or "none",
        sendMode = self.sendMode or "none",
        lastInitAt = self.lastInitAt or 0,
        readyAt = self.readyAt or 0,
        lastSendAt = self.lastSendAt or 0,
        lastReceiveAt = self.lastReceiveAt or 0,
    }
end

function Transport:CanSendConductorPayloads()
    return self.ready == true
end
