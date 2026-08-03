local C = Conductor
local SRC = SupportRotationCallouts
C.RunSync = C.RunSync or {}
local Sync = C.RunSync

Sync.PROTOCOL_ID = 237
Sync.PROTOCOL_NAME = "CONDUCTOR_RUN_SYNC_V1_DEV"
Sync.MAX_PAYLOAD = 190

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Normalize(name) return SRC.NormalizeAccountName and SRC:NormalizeAccountName(name or "") or tostring(name or "") end
local function Split(text, sep)
    local out, start = {}, 1
    text = tostring(text or "")
    while true do
        local pos = string.find(text, sep, start, true)
        if not pos then out[#out+1] = string.sub(text, start); break end
        out[#out+1] = string.sub(text, start, pos-1)
        start = pos + #sep
    end
    return out
end
local function Escape(value) return tostring(value or ""):gsub("%%", "%%25"):gsub("|", "%%7C") end
local function Unescape(value) return tostring(value or ""):gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex,16)) end) end

function Sync:DeclareProtocol()
    if self.protocol then return true end
    local LGB = LibGroupBroadcast
    local handler = C.NetworkTransport and C.NetworkTransport.handler
    if not LGB or not handler then return false, "network handler unavailable" end
    local ok, result = pcall(function()
        local protocol = handler:DeclareProtocol(self.PROTOCOL_ID, self.PROTOCOL_NAME)
        protocol:AddField(LGB.CreateStringField("payload", { minLength=1, maxLength=self.MAX_PAYLOAD }))
        protocol:OnData(function(first, second)
            local unitTag, values
            if type(first) == "table" then values, unitTag = first, second else unitTag, values = first, second end
            self:OnPayload(unitTag, values and values.payload or "")
        end)
        protocol:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=true })
        return protocol
    end)
    if not ok then self.lastError=tostring(result); return false, self.lastError end
    self.protocol = result
    self.ready = true
    return true
end

function Sync:SendPayload(payload)
    if not self.protocol then
        local ok = self:DeclareProtocol()
        if not ok then return false, self.lastError end
    end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then return false, "protocol disabled" end
    local ok, queued = pcall(self.protocol.Send, self.protocol, { payload=tostring(payload or "") })
    if ok and queued ~= false then self.lastSendAt=NowMs(); return true end
    self.lastError=tostring(queued or "message was not queued")
    return false, self.lastError
end

function Sync:EncodeHeader(run)
    return table.concat({"H",Escape(run.runId),Escape(run.hostAccount),Escape(run.trialId),Escape(run.difficulty),Escape(run.strategyId),tostring(run.revision or 1),tostring(run.startedAtMs or 0)},"|")
end
function Sync:BroadcastHeader()
    local run = C.RunContext and C.RunContext:Get()
    if not run or not C.RunContext:IsHost() then return false, "not hosting" end
    return self:SendPayload(self:EncodeHeader(run))
end
function Sync:BroadcastJoin()
    local run = C.RunContext and C.RunContext:Get()
    if not run or tostring(run.runId or "") == "" then return false, "no run" end
    return self:SendPayload(table.concat({"J",Escape(run.runId),Escape(GetDisplayName and GetDisplayName() or ""),Escape(run.combatRole),run.trialLeadView and "1" or "0"},"|"))
end
function Sync:BroadcastStop(reason)
    local run = C.RunContext and C.RunContext:Get()
    if not run or tostring(run.runId or "") == "" then return false end
    return self:SendPayload(table.concat({"S",Escape(run.runId),Escape(reason or "stopped")},"|"))
end
function Sync:BroadcastCheckpoint()
    local run = C.RunContext and C.RunContext:Get()
    if not run or not C.RunContext:IsHost() then return false end
    return self:SendPayload(table.concat({"C",Escape(run.runId),Escape(run.encounterId),Escape(run.phaseId),tostring(run.timelineStep or 0),tostring(run.sequenceRevision or 0)},"|"))
end

function Sync:OnPayload(unitTag, payload)
    local sender = unitTag and GetUnitDisplayName and GetUnitDisplayName(unitTag) or tostring(unitTag or "")
    sender = Normalize(sender)
    if sender == Normalize(GetDisplayName and GetDisplayName() or "") then return end
    if C.LiveSession and not C.LiveSession:IsAccountPresent(sender) then return end
    local p = Split(payload, "|")
    local kind = p[1]
    if kind == "H" then
        local header = { runId=Unescape(p[2]), hostAccount=Unescape(p[3]), trialId=Unescape(p[4]), difficulty=Unescape(p[5]), strategyId=Unescape(p[6]), revision=tonumber(p[7]) or 1, startedAtMs=tonumber(p[8]) or 0 }
        if header.hostAccount ~= sender then return end
        self.availableRun = header
        self.lastHeaderAt = NowMs()
        if C.EventBus then C.EventBus:Publish("RUN_SYNC_HEADER_RECEIVED", { sender=sender, header=header }) end
    elseif kind == "J" then
        local run = C.RunContext and C.RunContext:Get()
        if not run or not C.RunContext:IsHost() or tostring(run.runId) ~= Unescape(p[2]) then return end
        local account = Normalize(Unescape(p[3]))
        self.joined = self.joined or {}
        self.joined[account] = { account=account, combatRole=Unescape(p[4]), trialLeadView=p[5]=="1", lastSeenAt=NowMs() }
        if C.EventBus then C.EventBus:Publish("RUN_SYNC_CLIENT_JOINED", self.joined[account]) end
    elseif kind == "C" then
        local run = C.RunContext and C.RunContext:Get()
        if not run or C.RunContext:IsHost() or tostring(run.runId) ~= Unescape(p[2]) then return end
        C.RunContext:ApplyCheckpoint({ runId=Unescape(p[2]), encounterId=Unescape(p[3]), phaseId=Unescape(p[4]), timelineStep=tonumber(p[5]) or 0, sequenceRevision=tonumber(p[6]) or 0 })
    elseif kind == "S" then
        local run = C.RunContext and C.RunContext:Get()
        if run and tostring(run.runId) == Unescape(p[2]) then C.RunContext:Stop(Unescape(p[3])) end
    end
end

function Sync:StartGroupRun()
    if not C.RunContext then return false, "RunContext unavailable" end
    C.RunContext:Host()
    local ok, err = self:BroadcastHeader()
    if not ok then C.RunContext:Stop("run beacon failed"); return false, err end
    return true
end
function Sync:JoinAvailableRun()
    if not self.availableRun then return false, "no active run found" end
    local ok, err = C.RunContext:Join(self.availableRun)
    if not ok then return false, err end
    self:BroadcastJoin()
    return true
end
function Sync:StartLocalRun() C.RunContext:StartLocal("local mode"); return true end
function Sync:StopRun(reason)
    if C.RunContext and C.RunContext:IsHost() then self:BroadcastStop(reason) end
    if C.RunContext then C.RunContext:Stop(reason or "stopped by user") end
end
function Sync:GetStatus()
    local run = C.RunContext and C.RunContext:Get() or {}
    return { ready=self.ready==true, runState=run.state or "OFF", runId=run.runId or "", host=run.hostAccount or "", availableHost=self.availableRun and self.availableRun.hostAccount or "", joined=self.joined or {}, lastError=self.lastError }
end
function Sync:Initialize()
    self.joined = {}
    self.ready = false
    self:DeclareProtocol()
    self.initialized = true
end
