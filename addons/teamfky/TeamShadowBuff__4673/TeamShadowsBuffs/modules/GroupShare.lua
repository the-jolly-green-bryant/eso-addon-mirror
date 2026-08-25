TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs
local Module = {
    name = "GroupShare",
    protocolId = 442,
    maxPayloadLength = 6000,
    packetPrefix = "TSBX3",
    chunkLength = 700,
    maxAttempts = 3,
    recentBySender = {},
    incoming = {},
    outgoing = {},
    diagnostics = {},
    transferCounter = 0,
    diagnosticCounter = 0,
}

TSB.GroupShare = Module

local function Chat(message)
    if TSB.Chat then TSB.Chat(message) end
end

local function NowMs()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return (GetTimeStamp and GetTimeStamp() or 0) * 1000
end

local function IsSelf(unitTag)
    return AreUnitsEqual and AreUnitsEqual(unitTag, "player")
end

local function SenderName(unitTag)
    local name = GetUnitDisplayName and GetUnitDisplayName(unitTag)
    if name and name ~= "" then return name end
    name = GetUnitName and GetUnitName(unitTag)
    return (name and name ~= "") and name or tostring(unitTag or "joueur")
end

local function Hash(text)
    local hash = 5381
    for index = 1, #text do
        hash = (hash * 33 + string.byte(text, index)) % 2147483647
    end
    return hash
end

local function ValidPayload(payload)
    if type(payload) ~= "string" or payload == "" or #payload > Module.maxPayloadLength then return false end
    if payload:find("^TSB2:") then return payload:find(";E:", 1, true) ~= nil end
    if payload:find("^TSB1[;:]?") then return payload:find(";", 1, true) ~= nil end
    return false
end

local function IsShareLocationAllowed()
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then return true end
    if IsPlayerInAvAWorld and IsPlayerInAvAWorld() then return false end
    if GetCurrentZoneHouseId and (tonumber(GetCurrentZoneHouseId()) or 0) > 0 then return true end
    if IsInstanceEndlessDungeon and IsInstanceEndlessDungeon() then return true end
    if IsUnitInDungeon and IsUnitInDungeon("player") then
        if GetCurrentZoneDungeonDifficulty and DUNGEON_DIFFICULTY_NONE ~= nil then
            return GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE
        end
        return true
    end
    return false
end

function Module:IsLocationAllowed()
    return IsShareLocationAllowed()
end

local function GroupRecipients()
    local recipients = {}
    local size = GetGroupSize and GetGroupSize() or 0
    for index = 1, size do
        local unitTag = GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(index) or ("group" .. index)
        local exists = not DoesUnitExist or DoesUnitExist(unitTag)
        local online = not IsUnitOnline or IsUnitOnline(unitTag)
        if exists and online and not IsSelf(unitTag) then
            recipients[SenderName(unitTag)] = true
        end
    end
    return recipients
end

local function CountKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
end

local function Deliver(unitTag, payload)
    local now = NowMs()
    local signature = SenderName(unitTag) .. ":" .. tostring(Hash(payload))
    if Module.recentBySender[signature] and now - Module.recentBySender[signature] < 300000 then return end
    Module.recentBySender[signature] = now

    zo_callLater(function()
        if TSB.Manager and TSB.Manager.ReceiveGroupShare then
            TSB.Manager:ReceiveGroupShare(unitTag, payload)
        else
            TSB.pendingGroupShares = TSB.pendingGroupShares or {}
            TSB.pendingGroupShares[#TSB.pendingGroupShares + 1] = { unitTag = unitTag, payload = payload }
        end
    end, 50)
end

local function CleanupIncoming()
    local cutoff = NowMs() - 600000
    for key, transfer in pairs(Module.incoming) do
        if (transfer.updatedAt or 0) < cutoff then Module.incoming[key] = nil end
    end
end

local function MissingChunks(transfer)
    local current = GroupRecipients()
    for recipient in pairs(transfer.expected) do
        if not current[recipient] then transfer.expected[recipient] = nil end
    end

    local missing, missingRecipients = {}, {}
    for recipient in pairs(transfer.expected) do
        local acknowledged = transfer.acknowledged[recipient] or {}
        for index = 1, #transfer.chunks do
            if not acknowledged[index] then
                missing[index] = true
                missingRecipients[recipient] = true
            end
        end
    end
    return missing, missingRecipients
end

local function TransferDelayMs(packets)
    local frames = 0
    for _, packet in ipairs(packets) do
        frames = frames + math.ceil((#packet + 4) / 28)
    end
    return math.max(8000, (frames * 1400) + 5000)
end

function Module:QueuePacket(packet)
    if type(packet) ~= "string" or #packet < 4 or #packet > self.maxPayloadLength then return false end
    if not self.protocol and not self:InitializeProtocol() then return false end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then return false end
    local ok, sent = pcall(function()
        return self.protocol:Send({ payload = packet }, {
            isRelevantInCombat = false,
            replaceQueuedMessages = false,
        })
    end)
    return ok and sent == true
end

function Module:FinishTransfer(transfer, success, missingRecipients)
    if transfer.done then return end
    transfer.done = true
    self.outgoing[transfer.id] = nil
    local expectedCount = CountKeys(transfer.expected)
    if success then
        Chat(string.format("partage confirmé par %d/%d joueur(s).", expectedCount, expectedCount))
        return
    end

    local names = {}
    for name in pairs(missingRecipients or {}) do names[#names + 1] = name end
    table.sort(names)
    Chat(string.format("pas de confirmation fiable de %d joueur(s) (ancienne version ou réception bloquée) : %s. La copie compatible a aussi été envoyée.",
        #names, #names > 0 and table.concat(names, ", ") or "aucun destinataire compatible"))
end

function Module:ScheduleCheck(transfer, packets)
    local delay = TransferDelayMs(packets)
    zo_callLater(function()
        if transfer.done or Module.outgoing[transfer.id] ~= transfer then return end
        if IsUnitInCombat and IsUnitInCombat("player") then
            Module:ScheduleCheck(transfer, {})
            return
        end
        local missing, missingRecipients = MissingChunks(transfer)
        if not next(missing) then
            Module:FinishTransfer(transfer, true)
            return
        end
        if transfer.attempts >= Module.maxAttempts then
            Module:FinishTransfer(transfer, false, missingRecipients)
            return
        end

        transfer.attempts = transfer.attempts + 1
        local retryPackets = {}
        for index = 1, #transfer.chunks do
            if missing[index] then
                local packet = Module:BuildDataPacket(transfer, index)
                if Module:QueuePacket(packet) then retryPackets[#retryPackets + 1] = packet end
            end
        end
        Chat(string.format("partage : tentative %d/%d pour %d morceau(x) manquant(s).",
            transfer.attempts, Module.maxAttempts, #retryPackets))
        Module:ScheduleCheck(transfer, retryPackets)
    end, delay)
end

function Module:BuildDataPacket(transfer, index)
    return table.concat({
        self.packetPrefix, "D", transfer.id, tostring(transfer.hash), tostring(index),
        tostring(#transfer.chunks), transfer.chunks[index],
    }, "|")
end

function Module:BeginReliableTransfer(transfer)
    if transfer.done or self.outgoing[transfer.id] ~= transfer then return end
    if IsUnitInCombat and IsUnitInCombat("player") then
        zo_callLater(function() Module:BeginReliableTransfer(transfer) end, 5000)
        return
    end

    if not next(transfer.expected) then
        local recipientCount = CountKeys(transfer.recipients)
        transfer.done = true
        self.outgoing[transfer.id] = nil
        Chat(string.format("copie compatible envoyée à %d joueur(s). Confirmation automatique indisponible sur leurs versions.",
            recipientCount))
        return
    end

    transfer.started = true
    local packets = {}
    for index = 1, #transfer.chunks do
        local packet = self:BuildDataPacket(transfer, index)
        if self:QueuePacket(packet) then packets[#packets + 1] = packet end
    end
    if #packets ~= #transfer.chunks then
        self:FinishTransfer(transfer, false, transfer.expected)
        return
    end

    Chat(string.format("confirmation fiable active pour %d/%d joueur(s).",
        CountKeys(transfer.expected), CountKeys(transfer.recipients)))
    self:ScheduleCheck(transfer, packets)
end

function Module:StartReliableTransfer(payload)
    self.transferCounter = (self.transferCounter % 4095) + 1
    local stamp = GetTimeStamp and GetTimeStamp() or math.floor(NowMs() / 1000)
    local id = string.format("%x%x", stamp % 0x7FFFFFFF, self.transferCounter)
    local chunks = {}
    for offset = 1, #payload, self.chunkLength do
        chunks[#chunks + 1] = payload:sub(offset, offset + self.chunkLength - 1)
    end

    local transfer = {
        id = id,
        hash = Hash(payload),
        chunks = chunks,
        recipients = GroupRecipients(),
        expected = {},
        acknowledged = {},
        attempts = 1,
    }
    self.outgoing[id] = transfer

    local packets = {}
    if not self:QueuePacket(payload) then
        self.outgoing[id] = nil
        return false
    end
    packets[#packets + 1] = payload
    local hello = table.concat({ self.packetPrefix, "H", id }, "|")
    for _ = 1, 2 do
        if not self:QueuePacket(hello) then
            self.outgoing[id] = nil
            return false
        end
        packets[#packets + 1] = hello
    end

    Chat(string.format("copie compatible en cours vers %d destinataire(s) ; détection des confirmations...",
        CountKeys(transfer.recipients)))
    zo_callLater(function() Module:BeginReliableTransfer(transfer) end, TransferDelayMs(packets))
    return true
end

local function ReceiveReliable(unitTag, payload)
    local prefix = Module.packetPrefix
    local diagnosticId = payload:match("^" .. prefix .. "|Q|([%w_%-]+)$")
    if diagnosticId then
        Module:QueuePacket(table.concat({ prefix, "R", diagnosticId }, "|"))
        return true
    end

    local diagnosticResponseId = payload:match("^" .. prefix .. "|R|([%w_%-]+)$")
    if diagnosticResponseId then
        local diagnostic = Module.diagnostics[diagnosticResponseId]
        if diagnostic then diagnostic.responses[SenderName(unitTag)] = true end
        return true
    end

    local helloId = payload:match("^" .. prefix .. "|H|([%w_%-]+)$")
    if helloId then
        Module:QueuePacket(table.concat({ prefix, "P", helloId }, "|"))
        return true
    end

    local presenceId = payload:match("^" .. prefix .. "|P|([%w_%-]+)$")
    if presenceId then
        local transfer = Module.outgoing[presenceId]
        if transfer and not transfer.done and not transfer.started then
            local recipient = SenderName(unitTag)
            if transfer.recipients[recipient] then transfer.expected[recipient] = true end
        end
        return true
    end

    local transferId, hashText, indexText = payload:match("^" .. prefix .. "|A|([%w_%-]+)|(%d+)|(%d+)$")
    if transferId then
        local transfer = Module.outgoing[transferId]
        local hash, index = tonumber(hashText), tonumber(indexText)
        if not transfer or transfer.hash ~= hash or not transfer.chunks[index] then return true end
        local recipient = SenderName(unitTag)
        if not transfer.expected[recipient] then return true end
        transfer.acknowledged[recipient] = transfer.acknowledged[recipient] or {}
        transfer.acknowledged[recipient][index] = true
        local missing = MissingChunks(transfer)
        if not next(missing) then Module:FinishTransfer(transfer, true) end
        return true
    end

    local id, receivedHash, part, total, chunk = payload:match(
        "^" .. prefix .. "|D|([%w_%-]+)|(%d+)|(%d+)|(%d+)|(.*)$")
    if not id then return false end

    receivedHash, part, total = tonumber(receivedHash), tonumber(part), tonumber(total)
    local maxChunks = math.ceil(Module.maxPayloadLength / Module.chunkLength) + 1
    if not receivedHash or not part or not total or total < 1 or total > maxChunks or part < 1 or part > total then
        return true
    end

    CleanupIncoming()
    local sender = SenderName(unitTag)
    local key = sender .. ":" .. id
    local transfer = Module.incoming[key]
    if not transfer or transfer.hash ~= receivedHash or transfer.total ~= total then
        transfer = { hash = receivedHash, total = total, chunks = {}, received = 0 }
        Module.incoming[key] = transfer
    end
    transfer.updatedAt = NowMs()
    if not transfer.chunks[part] then
        transfer.chunks[part] = chunk
        transfer.received = transfer.received + 1
    end

    Module:QueuePacket(table.concat({ prefix, "A", id, tostring(receivedHash), tostring(part) }, "|"))
    if transfer.received ~= total or transfer.delivered then return true end

    local complete = table.concat(transfer.chunks)
    if #complete <= Module.maxPayloadLength and Hash(complete) == receivedHash and ValidPayload(complete) then
        transfer.delivered = true
        Deliver(unitTag, complete)
    else
        Module.incoming[key] = nil
    end
    return true
end

local function ReceivePayload(unitTag, data)
    if IsSelf(unitTag) then return end
    if IsUnitInCombat and IsUnitInCombat("player") then return end
    if not IsShareLocationAllowed() then return end
    local payload = data and data.payload
    if type(payload) ~= "string" then return end
    if ReceiveReliable(unitTag, payload) then return end
    if ValidPayload(payload) then Deliver(unitTag, payload) end
end

function Module:InitializeProtocol()
    if self.protocol then return true end
    if not LibGroupBroadcast or not LibGroupBroadcast.RegisterHandler or not LibGroupBroadcast.CreateStringField then
        self.lastProtocolError = "LibGroupBroadcast manquante"
        return false
    end

    local ok, handler, protocol = pcall(function()
        local h = LibGroupBroadcast:RegisterHandler("TeamShadowsBuffs")
        h:SetDisplayName("Team Shadows Buffs")
        h:SetDescription("Partage fiable de configurations de trackers entre les membres du groupe.")
        local p = h:DeclareProtocol(self.protocolId, "TeamShadowsBuffsConfig")
        p:AddField(LibGroupBroadcast.CreateStringField("payload", {
            minLength = 4,
            maxLength = self.maxPayloadLength,
        }))
        p:OnData(ReceivePayload)
        local finalized = p:Finalize({
            isRelevantInCombat = false,
            replaceQueuedMessages = false,
        })
        if finalized ~= true then return h, nil end
        return h, p
    end)

    if not ok or not handler or not protocol then
        self.lastProtocolError = not ok and tostring(handler) or "finalisation refusée"
        return false
    end

    self.handler = handler
    self.protocol = protocol
    self.lastProtocolError = nil
    return true
end

function Module:Send(payload)
    if not IsUnitGrouped or not IsUnitGrouped("player") then
        Chat("partage impossible : tu n'es pas dans un groupe.")
        return false
    end
    if IsUnitInCombat and IsUnitInCombat("player") then
        Chat("partage impossible : attends la fin du combat.")
        return false
    end
    if not IsShareLocationAllowed() then
        Chat("partage impossible en Cyrodiil et dans le monde ouvert : utilise une maison, un donjon, une épreuve, une arène ou un champ de bataille.")
        return false
    end
    if not ValidPayload(payload) then
        Chat("partage impossible : configuration invalide ou trop volumineuse.")
        return false
    end
    if not self:InitializeProtocol() then
        Chat("partage impossible : " .. tostring(self.lastProtocolError or "protocole indisponible") .. ".")
        return false
    end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then
        Chat("partage impossible : le protocole est désactivé dans LibGroupBroadcast.")
        return false
    end
    if self:QueuePacket(payload) then
        Chat("partage envoyé au groupe.")
        return true
    end
    Chat("l'envoi de la configuration a échoué.")
    return false
end

function Module:FinishDiagnostic(diagnostic)
    if self.diagnostics[diagnostic.id] ~= diagnostic then return end
    self.diagnostics[diagnostic.id] = nil

    local responders, missing = {}, {}
    for name in pairs(diagnostic.expected) do
        if diagnostic.responses[name] then
            responders[#responders + 1] = name
        else
            missing[#missing + 1] = name
        end
    end
    table.sort(responders)
    table.sort(missing)

    Chat(string.format("DIAG terminé : %d/%d joueur(s) répondent.", #responders, CountKeys(diagnostic.expected)))
    if #responders > 0 then Chat("DIAG OK : " .. table.concat(responders, ", ")) end
    if #missing > 0 then
        Chat("DIAG SANS RETOUR : " .. table.concat(missing, ", "))
        Chat("Pour ces joueurs : mettre à jour l'addon, puis vérifier LibGroupBroadcast > Team Shadows Buffs > Allow Sending.")
    end
end

function Module:RunDiagnostic()
    Chat("DIAG Team Shadows Buffs v" .. tostring(TSB.version or "?") .. ".")
    if not IsUnitGrouped or not IsUnitGrouped("player") then
        Chat("DIAG ARRÊT : tu n'es pas dans un groupe.")
        return false
    end
    if IsUnitInCombat and IsUnitInCombat("player") then
        Chat("DIAG ARRÊT : attends la fin du combat.")
        return false
    end
    if not self:InitializeProtocol() then
        Chat("DIAG ARRÊT : " .. tostring(self.lastProtocolError or "protocole indisponible") .. ".")
        return false
    end
    if self.protocol.IsEnabled and not self.protocol:IsEnabled() then
        Chat("DIAG ARRÊT : Allow Sending est désactivé dans LibGroupBroadcast > Team Shadows Buffs.")
        return false
    end

    local expected = GroupRecipients()
    local expectedCount = CountKeys(expected)
    if expectedCount == 0 then
        Chat("DIAG ARRÊT : aucun autre joueur connecté dans le groupe.")
        return false
    end

    self.diagnosticCounter = (self.diagnosticCounter % 4095) + 1
    local stamp = GetTimeStamp and GetTimeStamp() or math.floor(NowMs() / 1000)
    local id = string.format("d%x%x", stamp % 0x7FFFFFFF, self.diagnosticCounter)
    local diagnostic = { id = id, expected = expected, responses = {} }
    self.diagnostics[id] = diagnostic
    local packet = table.concat({ self.packetPrefix, "Q", id }, "|")
    local queued = self:QueuePacket(packet)
    if queued then queued = self:QueuePacket(packet) end
    if not queued then
        self.diagnostics[id] = nil
        Chat("DIAG ARRÊT : le signal de test n'a pas pu être envoyé.")
        return false
    end

    Chat(string.format("DIAG en cours vers %d joueur(s), résultat dans environ 18 secondes...", expectedCount))
    zo_callLater(function() Module:FinishDiagnostic(diagnostic) end, 18000)
    return true
end

function Module:Load()
    self:InitializeProtocol()
end

function Module:Unload()
end

TSB.RegisterModule(Module)
