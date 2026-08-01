local C = Conductor
local SRC = SupportRotationCallouts
C.PublicRaidContext = C.PublicRaidContext or {}
SRC.PublicRaidContext = C.PublicRaidContext
local Context = C.PublicRaidContext

Context.PROTOCOL_ID = 236
Context.PROTOCOL_NAME = "CONDUCTOR_RAID_CONTEXT_DEV"
Context.MAX_PAYLOAD = 180
Context.EXPIRES_MS = 8000

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Key(value) return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_") end
local function Escape(value) return tostring(value or ""):gsub("%%","%%25"):gsub("|","%%7C") end
local function Unescape(value) return tostring(value or ""):gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex,16)) end) end
local function Split(text)
    local result, start = {}, 1
    while true do
        local pos = string.find(text or "", "|", start, true)
        if not pos then result[#result+1] = string.sub(text or "", start); break end
        result[#result+1] = string.sub(text, start, pos-1); start = pos+1
    end
    return result
end

function Context:IsHost()
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local me = C.NormalizeAccountName and C:NormalizeAccountName(GetDisplayName and GetDisplayName() or "") or ""
    local host = session and (C.NormalizeAccountName and C:NormalizeAccountName(session.hostAccount or "") or session.hostAccount) or ""
    return session ~= nil and me ~= "" and me == host
end

function Context:Serialize(data)
    return table.concat({
        "1", Escape(data.sessionId), Escape(data.encounterId), Escape(data.state), Escape(data.instruction),
        Escape(data.windowId), tostring(data.revision or 0), tostring(data.sentAtMs or NowMs())
    }, "|")
end

function Context:Deserialize(payload)
    local parts = Split(payload)
    if parts[1] ~= "1" then return nil end
    return {
        schemaVersion=1, sessionId=Unescape(parts[2]), encounterId=Unescape(parts[3]),
        state=Key(Unescape(parts[4])), instruction=Key(Unescape(parts[5])), windowId=Unescape(parts[6]),
        revision=tonumber(parts[7]) or 0, sentAtMs=tonumber(parts[8]) or NowMs(),
    }
end

function Context:InitializeProtocol()
    if not LibGroupBroadcast or type(LibGroupBroadcast.RegisterHandler) ~= "function" then return false end
    local ok, handler = pcall(LibGroupBroadcast.RegisterHandler, LibGroupBroadcast, "ConductorRaidContext", "Conductor")
    if not ok or not handler then return false end
    local okProtocol, protocol = pcall(handler.DeclareProtocol, handler, self.PROTOCOL_ID, self.PROTOCOL_NAME)
    if not okProtocol or not protocol then return false end
    if protocol.SetDisplayName then pcall(protocol.SetDisplayName, protocol, "Conductor Raid Context") end
    if protocol.SetDescription then pcall(protocol.SetDescription, protocol, "Shares only current raid-wide hold, push, burn, execute, and transition context.") end
    local field = LibGroupBroadcast.CreateStringField("payload", {maxLength=self.MAX_PAYLOAD})
    protocol:AddField(field)
    protocol:OnData(function(first, second)
        local unitTag, values = first, second
        if type(first) == "table" then values, unitTag = first, second end
        self:Receive(unitTag, type(values)=="table" and values.payload or "")
    end)
    protocol:Finalize({isRelevantInCombat=true, replaceQueuedMessages=true})
    self.protocol = protocol
    self.ready = true
    return true
end

function Context:Publish(data)
    data = data or {}
    data.sentAtMs = NowMs()
    self.current = data
    if C.EventBus then C.EventBus:Publish("PUBLIC_RAID_CONTEXT_UPDATED", {context=data, localHost=true}) end
    if not self:IsHost() or not self.ready or not self.protocol then return false end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then return false end
    local ok = pcall(self.protocol.Send, self.protocol, {payload=self:Serialize(data)}, {replaceQueuedMessages=true})
    return ok
end

function Context:Receive(unitTag, payload)
    local data = self:Deserialize(payload)
    if not data then return false end
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    if session and session.sessionId and data.sessionId ~= "" and session.sessionId ~= data.sessionId then return false end
    data.receivedAtMs = NowMs()
    data.senderUnitTag = unitTag
    self.current = data
    if C.EventBus then C.EventBus:Publish("PUBLIC_RAID_CONTEXT_UPDATED", {context=data, localHost=false}) end
    return true
end

function Context:GetCurrent()
    if self.current and NowMs() - tonumber(self.current.receivedAtMs or self.current.sentAtMs or 0) <= self.EXPIRES_MS then return self.current end
    return nil
end

function Context:Initialize()
    self:InitializeProtocol()
    EVENT_MANAGER:RegisterForUpdate((SRC.name or "Conductor") .. "RaidContextExpiry", 1000, function()
        if self.current and not self:GetCurrent() then
            self.current = nil
            if C.EventBus then C.EventBus:Publish("PUBLIC_RAID_CONTEXT_EXPIRED", {}) end
        end
    end)
    self.initialized = true
end
