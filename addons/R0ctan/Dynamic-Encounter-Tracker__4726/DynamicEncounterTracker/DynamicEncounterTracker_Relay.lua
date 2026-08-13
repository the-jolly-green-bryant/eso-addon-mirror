local DE = DynamicEncounterTracker
local Relay = {}

local BASE36_ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local RELAY_PREFIX = "DE"
local RELAY_PROTOCOL_VERSION = "1"
local RELAY_MESSAGE_TYPE_TIMER = "T"
local RELAY_MESSAGE_TYPE_ENCOUNTER = "E"
local RELAY_MESSAGE_TYPE_REQUEST = "R"
local RELAY_VISIBLE_PREFIX = "DynEnc"
local RELAY_AGE_UNIT_SECONDS = 5
local RELAY_MAX_AGE_UNITS = 1295 -- 36^2 - 1
local RELAY_SEQUENCE_MODULUS = 1296 -- 36^2
local RELAY_CHECKSUM_MODULUS = 60466176 -- 36^5
local RELAY_PROGRESS_BUCKET_COUNT = 36
local RELAY_DUPLICATE_WINDOW_SECONDS = 120
-- Keep re-show support long enough for a reload, but never revive stale messages indefinitely.
local RELAY_LAST_RECEIVED_MAX_AGE_SECONDS = 3600
local RELAY_CODE_OF_CONDUCT_WAIT_SECONDS = 10
-- Bump after meaningful notice changes so existing users confirm the new text once.
local RELAY_CODE_OF_CONDUCT_VERSION = 2
-- Guild-wide requests use "*" as their relay code; all encounter codes stay alphanumeric.
local RELAY_BLOCK_PATTERN = "%[(DE%d%a[%w*]+)%]"
-- Throttle this addon's outgoing messages independently per channel.
local RELAY_CHANNEL_SPAM_WINDOW_SECONDS = 30
local RELAY_TIMER_BLOCK_LENGTH = 14
local RELAY_ENCOUNTER_BLOCK_LENGTH = 15
-- DE(2) + protocolVersion(1) + messageType(1) + relayCode(1) + sequenceField(2)
-- + checksum(5, see BuildRelayChecksum/RELAY_CHECKSUM_MODULUS=36^5) = 12.
local RELAY_REQUEST_BLOCK_LENGTH = 12
-- Guild requests are encounter-independent; "*" cannot collide with configured codes.
local RELAY_REQUEST_WILDCARD = "*"
-- Allow time for responders to confirm manually because StartTextEntry never sends chat.
local RELAY_REQUEST_COLLECTION_WINDOW_SECONDS = 60
-- Exposed on DE (not just local) so DynamicEncounterTracker_Settings.lua can
-- use the same bounds for its slider without duplicating the numbers.
DE.RELAY_REQUEST_COLLECTION_WINDOW_MIN_SECONDS = 15
DE.RELAY_REQUEST_COLLECTION_WINDOW_MAX_SECONDS = 120
local RELAY_REQUEST_COLLECTION_WINDOW_MIN_SECONDS = DE.RELAY_REQUEST_COLLECTION_WINDOW_MIN_SECONDS
local RELAY_REQUEST_COLLECTION_WINDOW_MAX_SECONDS = DE.RELAY_REQUEST_COLLECTION_WINDOW_MAX_SECONDS
-- Independent per-requester cooldown for reacting to incoming requests, keyed by
-- "REQ:"..fromDisplayName so it never shares state with the channel spam guard.
local RELAY_REQUEST_SENDER_COOLDOWN_SECONDS = 60
local RELAY_GUILD_CHANNEL_TYPES = {
    CHAT_CHANNEL_GUILD_1,
    CHAT_CHANNEL_GUILD_2,
    CHAT_CHANNEL_GUILD_3,
    CHAT_CHANNEL_GUILD_4,
    CHAT_CHANNEL_GUILD_5,
}

local function EncodeBase36(value, length)
    value = zo_floor(tonumber(value) or 0)
    if value < 0 then
        value = 0
    end

    local modulus = 36 ^ length
    value = value % modulus

    local digits = {}
    for position = length, 1, -1 do
        local remainder = value % 36
        digits[position] = BASE36_ALPHABET:sub(remainder + 1, remainder + 1)
        value = zo_floor(value / 36)
    end

    return table.concat(digits)
end

local function DecodeBase36(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end

    local value = 0
    for i = 1, #text do
        local character = text:sub(i, i)
        local digitValue = BASE36_ALPHABET:find(character, 1, true)
        if not digitValue then
            return nil
        end
        value = value * 36 + (digitValue - 1)
    end

    return value
end

-- Whisper guards and checksums are keyed per recipient.
local function ChannelTypeToName(channelType, targetDisplayName)
    if channelType == CHAT_CHANNEL_SAY then
        return "SAY"
    elseif channelType == CHAT_CHANNEL_ZONE then
        return "ZONE"
    elseif channelType == CHAT_CHANNEL_WHISPER then
        return "WHISPER:" .. tostring(targetDisplayName)
    end
    for guildIndex, guildChannelType in ipairs(RELAY_GUILD_CHANNEL_TYPES) do
        if channelType == guildChannelType then
            return "GUILD" .. guildIndex
        end
    end
    return nil
end

-- Guild slots are account-local, so this mapping is valid only after receipt and
-- must never be used as cross-client checksum input.
local function ChannelTypeToGuildId(channelType)
    for guildIndex, guildChannelType in ipairs(RELAY_GUILD_CHANNEL_TYPES) do
        if channelType == guildChannelType then
            return GetGuildId(guildIndex)
        end
    end
    return nil
end

function DE:GetActiveGuildChannels()
    local channels = {}
    local numGuilds = GetNumGuilds()
    for guildIndex = 1, numGuilds do
        local guildId = GetGuildId(guildIndex)
        local channelType = RELAY_GUILD_CHANNEL_TYPES[guildIndex]
        if guildId and channelType then
            channels[#channels + 1] = {
                guildIndex = guildIndex,
                guildId = guildId,
                guildName = GetGuildName(guildId),
                channelType = channelType,
            }
        end
    end
    return channels
end

-- Time-bound relay travel so a failed jump cannot preserve state indefinitely.
local RELAY_TRAVEL_GRACE_SECONDS = 20
function DE:MarkRelayTravelPending()
    self:EnsureRelayState().travelPendingUntil = GetTimeStamp() + RELAY_TRAVEL_GRACE_SECONDS
end

function DE:IsRelayTravelPending()
    local until_ = self:EnsureRelayState().travelPendingUntil
    return until_ ~= nil and GetTimeStamp() < until_
end

function DE:ClearRelayTravelPending()
    self:EnsureRelayState().travelPendingUntil = nil
end

-- Reset all own, received, and pending relay state through normal zone detection.
function DE:ResetOwnRelayTimer()
    local relayState = self:EnsureRelayState()
    relayState.timerSource = nil
    relayState.pendingGuildRelayAccept = nil
    self:UpdateCurrentZone(true)
    self.state.guildRelayEntries = {}
    if self.GuildRelayWindow then
        self.GuildRelayWindow:Refresh()
    end
    self:Print(self:T("DE_RELAY_RESET_DONE"))
end

function DE:EnsureRelayState()
    self.state.relay = self.state.relay or {
        timerSource = nil,
        recentMessages = {},
        lastSequenceBySender = {},
        channelSpamGuard = {},
    }
    return self.state.relay
end

-- Only this player's outgoing messages count; incoming traffic must not block replies.
function DE:IsChannelSpamBlocked(channelName)
    local relayState = self:EnsureRelayState()
    local lastActivityAt = relayState.channelSpamGuard[channelName]
    if not lastActivityAt then
        return false
    end

    local elapsed = GetTimeStamp() - lastActivityAt
    if elapsed >= RELAY_CHANNEL_SPAM_WINDOW_SECONDS then
        return false
    end

    return true, RELAY_CHANNEL_SPAM_WINDOW_SECONDS - elapsed
end

function DE:MarkChannelRelayActivity(channelName)
    local relayState = self:EnsureRelayState()
    relayState.channelSpamGuard[channelName] = GetTimeStamp()
end

-- Reject stale chat replays while tolerating sequence wrap-around and minor reordering.
function DE:IsRelayMessageSequenceStale(fromDisplayName, sequence)
    local relayState = self:EnsureRelayState()
    local lastSeen = relayState.lastSequenceBySender[fromDisplayName]
    if lastSeen == nil or sequence == nil or sequence == lastSeen then
        return false
    end

    local backwardDistance = (lastSeen - sequence) % RELAY_SEQUENCE_MODULUS
    return backwardDistance > 0 and backwardDistance < (RELAY_SEQUENCE_MODULUS / 2)
end

function DE:BuildRelayChecksum(protocolVersion, messageType, relayCode, ageField, sequenceField, channelName, displayName)
    local hashInput = table.concat({
        protocolVersion,
        messageType,
        relayCode,
        ageField,
        sequenceField,
        tostring(channelName),
        tostring(displayName),
    }, "|")

    local hash = 0
    for i = 1, #hashInput do
        hash = (hash * 31 + string.byte(hashInput, i)) % 4294967296
    end

    return EncodeBase36(hash % RELAY_CHECKSUM_MODULUS, 5)
end

-- Whisper responses and guild shares may be sent outside the encounter zone.
function DE:EncodeRelayTimerMessage(config, channelType, target)
    local channelName = ChannelTypeToName(channelType, target)
    if not channelName then
        return nil, "unsupported-channel"
    end

    if not config or type(config.relayCode) ~= "string" or config.relayCode == "" then
        return nil, "unknown-encounter"
    end

    if self:IsChannelSpamBlocked(channelName) then
        return nil, "channel-cooldown"
    end

    local relayState = self:EnsureRelayState()
    if self.state.status ~= self.STATUS_COOLDOWN
        or not self.state.cooldownStartedAt
        or self.state.eventData ~= config then
        return nil, "no-timer"
    end
    if relayState.timerSource ~= "self" then
        return nil, "not-own-timer"
    end

    -- The sender must still physically be in the encounter's zone. state.eventData
    -- is normally cleared on any zone change (see SetUnknownState), but this is a
    -- deliberate extra safeguard against relying on that alone.
    local isFakeZone = relayState.debugFakeZone or channelType == CHAT_CHANNEL_WHISPER
    if not isFakeZone then
        local _, _, currentConfigs = self:GetCurrentZoneData()
        local stillInZone = false
        if type(currentConfigs) == "table" then
            for _, candidate in ipairs(currentConfigs) do
                if candidate == config then
                    stillInZone = true
                    break
                end
            end
        end
        if not stillInZone then
            return nil, "no-timer"
        end
    end

    local eventAgeSeconds = zo_max(0, GetTimeStamp() - self.state.cooldownStartedAt)
    local ageUnits = zo_clamp(zo_floor((eventAgeSeconds / RELAY_AGE_UNIT_SECONDS) + 0.5), 0, RELAY_MAX_AGE_UNITS)
    local ageField = EncodeBase36(ageUnits, 2)

    self.sv.relaySequence = ((tonumber(self.sv.relaySequence) or 0) + 1) % RELAY_SEQUENCE_MODULUS
    local sequenceField = EncodeBase36(self.sv.relaySequence, 2)

    local displayName = GetDisplayName()
    -- Guild slots differ between accounts, so checksum input must be slot-independent.
    local checksumChannelKey = channelName:find("^GUILD") and "GUILD" or channelName
    local checksum = self:BuildRelayChecksum(
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_TIMER,
        config.relayCode,
        ageField,
        sequenceField,
        checksumChannelKey,
        displayName
    )

    local block = string.format(
        "%s%s%s%s%s%s%s",
        RELAY_PREFIX,
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_TIMER,
        config.relayCode,
        ageField,
        sequenceField,
        checksum
    )

    local remainingSeconds = zo_max(0, (self.state.respawnAt or GetTimeStamp()) - GetTimeStamp())
    local readableTime = self:FormatRespawnTime(remainingSeconds)
    local zoneName = config.relayZoneNameEn or config.relayCode

    return string.format("%s: %s respawn is in %s [%s]", RELAY_VISIBLE_PREFIX, zoneName, readableTime, block)
end

-- Whisper responses support active encounters as well as timers.
function DE:EncodeRelayEncounterMessage(config, channelType, target)
    local channelName = ChannelTypeToName(channelType, target)
    if not channelName or not (channelName:find("^GUILD") or channelType == CHAT_CHANNEL_WHISPER) then
        return nil, "unsupported-channel"
    end

    if not config or type(config.relayCode) ~= "string" or config.relayCode == "" then
        return nil, "unknown-encounter"
    end

    if self:IsChannelSpamBlocked(channelName) then
        return nil, "channel-cooldown"
    end

    if self.state.status ~= self.STATUS_ACTIVE or self.state.eventData ~= config then
        return nil, "no-encounter"
    end
    if self.state.activeSource then
        return nil, "not-own-encounter"
    end

    local eventAgeSeconds = zo_max(0, GetTimeStamp() - (self.state.activeStartedAt or GetTimeStamp()))
    local ageUnits = zo_clamp(zo_floor((eventAgeSeconds / RELAY_AGE_UNIT_SECONDS) + 0.5), 0, RELAY_MAX_AGE_UNITS)
    local ageField = EncodeBase36(ageUnits, 2)

    local maxProgress = tonumber(self.state.maxProgress) or 0
    local currentProgress = tonumber(self.state.currentProgress) or 0
    local percent = 0
    if maxProgress > 0 then
        percent = zo_clamp((currentProgress / maxProgress) * 100, 0, 100)
    end
    local progressBucket = zo_clamp(zo_floor((percent / 100) * RELAY_PROGRESS_BUCKET_COUNT), 0, RELAY_PROGRESS_BUCKET_COUNT - 1)
    local progressField = EncodeBase36(progressBucket, 1)

    self.sv.relaySequence = ((tonumber(self.sv.relaySequence) or 0) + 1) % RELAY_SEQUENCE_MODULUS
    local sequenceField = EncodeBase36(self.sv.relaySequence, 2)

    local displayName = GetDisplayName()
    -- Guild checksums stay slot-independent; whisper channel names already include the target.
    local checksumChannelKey = channelType == CHAT_CHANNEL_WHISPER and channelName or "GUILD"
    local checksum = self:BuildRelayChecksum(
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_ENCOUNTER,
        config.relayCode,
        ageField .. progressField,
        sequenceField,
        checksumChannelKey,
        displayName
    )

    local block = string.format(
        "%s%s%s%s%s%s%s%s",
        RELAY_PREFIX,
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_ENCOUNTER,
        config.relayCode,
        ageField,
        progressField,
        sequenceField,
        checksum
    )

    local zoneName = config.relayZoneNameEn or config.relayCode

    return string.format("%s: %s encounter is active (~%d%%) [%s]", RELAY_VISIBLE_PREFIX, zoneName, zo_floor(percent), block)
end

-- Say/zone requests name the local encounter; guild requests use the wildcard.
function DE:EncodeRelayTimerRequest(config, channelType)
    local channelName = ChannelTypeToName(channelType)
    if not channelName then
        return nil, "unsupported-channel"
    end

    local isGuildChannel = channelName:find("^GUILD") ~= nil
    if not isGuildChannel and (not config or type(config.relayCode) ~= "string" or config.relayCode == "") then
        return nil, "unknown-encounter"
    end

    if self:IsChannelSpamBlocked(channelName) then
        return nil, "channel-cooldown"
    end

    local relayCode = isGuildChannel and RELAY_REQUEST_WILDCARD or config.relayCode

    self.sv.relaySequence = ((tonumber(self.sv.relaySequence) or 0) + 1) % RELAY_SEQUENCE_MODULUS
    local sequenceField = EncodeBase36(self.sv.relaySequence, 2)

    local displayName = GetDisplayName()
    -- See EncodeRelayTimerMessage for why guild channels use a fixed,
    -- slot-independent label instead of ChannelTypeToGuildId here.
    local checksumChannelKey = isGuildChannel and "GUILD" or channelName
    local checksum = self:BuildRelayChecksum(
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_REQUEST,
        relayCode,
        "",
        sequenceField,
        checksumChannelKey,
        displayName
    )

    local block = string.format(
        "%s%s%s%s%s%s",
        RELAY_PREFIX,
        RELAY_PROTOCOL_VERSION,
        RELAY_MESSAGE_TYPE_REQUEST,
        relayCode,
        sequenceField,
        checksum
    )

    if relayCode == RELAY_REQUEST_WILDCARD then
        return string.format("%s: timer/encounter requested [%s]", RELAY_VISIBLE_PREFIX, block), sequenceField
    end

    local zoneName = config.relayZoneNameEn or config.relayCode
    return string.format("%s: %s timer requested [%s]", RELAY_VISIBLE_PREFIX, zoneName, block), sequenceField
end

-- Extracts and splits the protocol block from a chat text. Does not validate against
-- game state - pure text decoding only.
function DE:DecodeRelayMessage(text)
    if type(text) ~= "string" then
        return nil, "invalid-payload"
    end

    local block = text:match(RELAY_BLOCK_PATTERN)
    if not block then
        return nil, "invalid-payload"
    end

    local prefix = block:sub(1, 2)
    if prefix ~= RELAY_PREFIX then
        return nil, "invalid-payload"
    end

    local protocolVersion = block:sub(3, 3)
    local messageType = block:sub(4, 4)

    if protocolVersion ~= RELAY_PROTOCOL_VERSION then
        return nil, "unsupported-protocol-version"
    end

    if messageType == RELAY_MESSAGE_TYPE_TIMER then
        return self:DecodeRelayTimerBlock(block)
    elseif messageType == RELAY_MESSAGE_TYPE_ENCOUNTER then
        return self:DecodeRelayEncounterBlock(block)
    elseif messageType == RELAY_MESSAGE_TYPE_REQUEST then
        return self:DecodeRelayRequestBlock(block)
    end

    return nil, "unknown-message-type"
end

function DE:DecodeRelayTimerBlock(block)
    if #block ~= RELAY_TIMER_BLOCK_LENGTH then
        return nil, "invalid-payload"
    end

    local protocolVersion = block:sub(3, 3)
    local messageType = block:sub(4, 4)
    local relayCode = block:sub(5, 5)
    local ageField = block:sub(6, 7)
    local sequenceField = block:sub(8, 9)
    local checksum = block:sub(10, 14)

    local ageUnits = DecodeBase36(ageField)
    local sequence = DecodeBase36(sequenceField)
    if not ageUnits or not sequence then
        return nil, "invalid-data"
    end

    return {
        protocolVersion = protocolVersion,
        messageType = messageType,
        relayCode = relayCode,
        ageField = ageField,
        ageUnits = ageUnits,
        sequenceField = sequenceField,
        sequence = sequence,
        checksum = checksum,
    }
end

function DE:DecodeRelayEncounterBlock(block)
    if #block ~= RELAY_ENCOUNTER_BLOCK_LENGTH then
        return nil, "invalid-payload"
    end

    local protocolVersion = block:sub(3, 3)
    local messageType = block:sub(4, 4)
    local relayCode = block:sub(5, 5)
    local ageField = block:sub(6, 7)
    local progressField = block:sub(8, 8)
    local sequenceField = block:sub(9, 10)
    local checksum = block:sub(11, 15)

    local ageUnits = DecodeBase36(ageField)
    local progressBucket = DecodeBase36(progressField)
    local sequence = DecodeBase36(sequenceField)
    if not ageUnits or not progressBucket or not sequence then
        return nil, "invalid-data"
    end

    return {
        protocolVersion = protocolVersion,
        messageType = messageType,
        relayCode = relayCode,
        ageField = ageField,
        ageUnits = ageUnits,
        progressField = progressField,
        progressBucket = progressBucket,
        sequenceField = sequenceField,
        sequence = sequence,
        checksum = checksum,
    }
end

function DE:DecodeRelayRequestBlock(block)
    if #block ~= RELAY_REQUEST_BLOCK_LENGTH then
        return nil, "invalid-payload"
    end

    local protocolVersion = block:sub(3, 3)
    local messageType = block:sub(4, 4)
    local relayCode = block:sub(5, 5)
    local sequenceField = block:sub(6, 7)
    local checksum = block:sub(8, 12)

    local sequence = DecodeBase36(sequenceField)
    if not sequence then
        return nil, "invalid-data"
    end

    return {
        protocolVersion = protocolVersion,
        messageType = messageType,
        relayCode = relayCode,
        sequenceField = sequenceField,
        sequence = sequence,
        checksum = checksum,
    }
end

-- Validates a decoded message against the actual chat event context and local state.
-- Returns true, config on success, or false, reasonKey on rejection.
function DE:ValidateRelayMessage(decoded, channelType, fromDisplayName, skipPriorityCheck, skipDuplicateCheck)
    if decoded.messageType == RELAY_MESSAGE_TYPE_ENCOUNTER then
        return self:ValidateRelayEncounterMessage(decoded, channelType, fromDisplayName, skipPriorityCheck, skipDuplicateCheck)
    elseif decoded.messageType == RELAY_MESSAGE_TYPE_REQUEST then
        return self:ValidateRelayRequestMessage(decoded, channelType, fromDisplayName, skipDuplicateCheck)
    end
    return self:ValidateRelayTimerMessage(decoded, channelType, fromDisplayName, skipPriorityCheck, skipDuplicateCheck)
end

function DE:ValidateRelayTimerMessage(decoded, channelType, fromDisplayName, skipPriorityCheck, skipDuplicateCheck)
    -- Received whispers use our own display name as the channel key, mirroring
    -- what the sender used as target when whispering us (see EncodeRelayTimerMessage).
    local channelName = ChannelTypeToName(channelType, channelType == CHAT_CHANNEL_WHISPER and GetDisplayName() or nil)
    if not channelName then
        return false, "unsupported-channel"
    end

    -- Say/zone and guild/whisper receiving have independent user controls.
    local isGuildChannel = channelName:find("^GUILD") ~= nil
    if not isGuildChannel and channelType ~= CHAT_CHANNEL_WHISPER and not self.sv.relayReceiveEnabled then
        return false, "relay-disabled"
    end
    if isGuildChannel and not self.sv.relayGuildReceiveEnabled then
        return false, "relay-disabled"
    end

    if fromDisplayName == GetDisplayName() then
        return false, "self-message"
    end

    local config = self:GetEncounterConfigByRelayCode(decoded.relayCode)
    if not config then
        return false, "unknown-encounter"
    end

    -- Guild and whisper timers are travel targets; say and zone require local presence.
    local skipsZoneCheck = isGuildChannel or channelType == CHAT_CHANNEL_WHISPER
    if not skipsZoneCheck then
        -- Development-only fake zones must validate against the simulated state.
        local currentConfigs
        if self:EnsureRelayState().debugFakeZone then
            currentConfigs = self.state.zoneEncounterConfigs
        else
            local _, _, zoneConfigs = self:GetCurrentZoneData()
            currentConfigs = zoneConfigs
        end

        local zoneMatches = false
        if type(currentConfigs) == "table" then
            for _, candidate in ipairs(currentConfigs) do
                if candidate == config then
                    zoneMatches = true
                    break
                end
            end
        end
        if not zoneMatches then
            return false, "zone-mismatch"
        end
    end

    -- See EncodeRelayTimerMessage for why guild channels use a fixed,
    -- slot-independent label instead of ChannelTypeToGuildId here.
    local checksumChannelKey = isGuildChannel and "GUILD" or channelName
    local expectedChecksum = self:BuildRelayChecksum(
        decoded.protocolVersion,
        decoded.messageType,
        decoded.relayCode,
        decoded.ageField,
        decoded.sequenceField,
        checksumChannelKey,
        fromDisplayName
    )
    if expectedChecksum ~= decoded.checksum then
        return false, "checksum-mismatch"
    end

    local relayState = self:EnsureRelayState()
    local dedupKey = fromDisplayName .. "|" .. decoded.sequenceField
    local now = GetTimeStamp()
    -- /dynet accept revalidates a stored message, not a newly received duplicate.
    if not skipDuplicateCheck and relayState.recentMessages[dedupKey] and (now - relayState.recentMessages[dedupKey]) < RELAY_DUPLICATE_WINDOW_SECONDS then
        return false, "duplicate"
    end

    -- Sequence checks catch replays beyond the short duplicate window.
    if not skipDuplicateCheck and self:IsRelayMessageSequenceStale(fromDisplayName, decoded.sequence) then
        return false, "stale-replay"
    end

    -- Own-timer priority applies only to local say/zone suggestions; guild shares
    -- represent another instance and must remain available in the relay list.
    if not isGuildChannel and not skipPriorityCheck and self.state.status == self.STATUS_COOLDOWN and relayState.timerSource ~= nil then
        return false, "own-timer-present"
    end

    return true, config
end

-- Encounter shares identify another instance, so guild/whisper messages have no
-- local-zone or own-encounter priority check. Keep skipPriorityCheck for dispatch parity.
function DE:ValidateRelayEncounterMessage(decoded, channelType, fromDisplayName, skipPriorityCheck, skipDuplicateCheck)
    local channelName = ChannelTypeToName(channelType, channelType == CHAT_CHANNEL_WHISPER and GetDisplayName() or nil)
    local isGuildChannel = channelName and channelName:find("^GUILD") ~= nil
    if not channelName or not (isGuildChannel or channelType == CHAT_CHANNEL_WHISPER) then
        return false, "unsupported-channel"
    end

    -- Whisper responses are direct replies to this player's pending request.
    if isGuildChannel and not self.sv.relayGuildReceiveEnabled then
        return false, "relay-disabled"
    end

    if fromDisplayName == GetDisplayName() then
        return false, "self-message"
    end

    local config = self:GetEncounterConfigByRelayCode(decoded.relayCode)
    if not config then
        return false, "unknown-encounter"
    end

    -- See EncodeRelayTimerMessage for why guild channels use a fixed,
    -- slot-independent label instead of ChannelTypeToGuildId here.
    local checksumChannelKey = isGuildChannel and "GUILD" or channelName
    local expectedChecksum = self:BuildRelayChecksum(
        decoded.protocolVersion,
        decoded.messageType,
        decoded.relayCode,
        decoded.ageField .. decoded.progressField,
        decoded.sequenceField,
        checksumChannelKey,
        fromDisplayName
    )
    if expectedChecksum ~= decoded.checksum then
        return false, "checksum-mismatch"
    end

    local relayState = self:EnsureRelayState()
    local dedupKey = fromDisplayName .. "|" .. decoded.sequenceField
    local now = GetTimeStamp()
    -- See the timer variant above for why /dynet accept must skip this check.
    if not skipDuplicateCheck and relayState.recentMessages[dedupKey] and (now - relayState.recentMessages[dedupKey]) < RELAY_DUPLICATE_WINDOW_SECONDS then
        return false, "duplicate"
    end

    -- See the timer variant above for why /dynet accept must skip this check.
    if not skipDuplicateCheck and self:IsRelayMessageSequenceStale(fromDisplayName, decoded.sequence) then
        return false, "stale-replay"
    end

    return true, config
end

-- Requests carry no state; response eligibility is evaluated separately.
function DE:ValidateRelayRequestMessage(decoded, channelType, fromDisplayName, skipDuplicateCheck)
    local channelName = ChannelTypeToName(channelType)
    if not channelName then
        return false, "unsupported-channel"
    end

    if not self.sv.relayRequestReceiveEnabled then
        return false, "relay-disabled"
    end

    if fromDisplayName == GetDisplayName() then
        -- Start collection on the matching chat echo, after the requester actually sends.
        local relayState = self:EnsureRelayState()
        local pending = relayState.pendingRequest
        if pending and not pending.sentAt and pending.relayCode == decoded.relayCode and pending.sequenceField == decoded.sequenceField then
            self:ArmRelayPendingRequest()
        end
        return false, "self-message"
    end

    -- Encounter-independent wildcard requests are valid only in guild channels.
    local isWildcard = decoded.relayCode == RELAY_REQUEST_WILDCARD
    if isWildcard and not channelName:find("^GUILD") then
        return false, "unsupported-channel"
    end
    local config = nil
    if not isWildcard then
        config = self:GetEncounterConfigByRelayCode(decoded.relayCode)
        if not config then
            return false, "unknown-encounter"
        end
    end

    -- See EncodeRelayTimerMessage for why guild channels use a fixed,
    -- slot-independent label instead of ChannelTypeToGuildId here.
    local checksumChannelKey = channelName:find("^GUILD") and "GUILD" or channelName
    local expectedChecksum = self:BuildRelayChecksum(
        decoded.protocolVersion,
        decoded.messageType,
        decoded.relayCode,
        "",
        decoded.sequenceField,
        checksumChannelKey,
        fromDisplayName
    )
    if expectedChecksum ~= decoded.checksum then
        return false, "checksum-mismatch"
    end

    local relayState = self:EnsureRelayState()
    local dedupKey = fromDisplayName .. "|" .. decoded.sequenceField
    local now = GetTimeStamp()
    if not skipDuplicateCheck and relayState.recentMessages[dedupKey] and (now - relayState.recentMessages[dedupKey]) < RELAY_DUPLICATE_WINDOW_SECONDS then
        return false, "duplicate"
    end

    -- A single per-sender sequence covers requests, timers, and encounters.
    if not skipDuplicateCheck and self:IsRelayMessageSequenceStale(fromDisplayName, decoded.sequence) then
        return false, "stale-replay"
    end

    return true, config
end

function DE:CleanupRelayDuplicateCache()
    local relayState = self:EnsureRelayState()
    local now = GetTimeStamp()
    for key, receivedAt in pairs(relayState.recentMessages) do
        if (now - receivedAt) >= RELAY_DUPLICATE_WINDOW_SECONDS then
            relayState.recentMessages[key] = nil
        end
    end
end

-- Notify only for malformed/tampered messages; routine rejections would be noisy.
local RELAY_INTEGRITY_FAILURE_REASONS = {
    ["invalid-payload"] = true,
    ["unsupported-protocol-version"] = true,
    ["unknown-message-type"] = true,
    ["invalid-data"] = true,
    ["checksum-mismatch"] = true,
}

-- Whisper is only relevant while the player is actively waiting on responses to
-- their own request (see pendingRequest) - a normal, unrelated whisper is never
-- expected to carry the relay tag anyway, so this is cheap to check unconditionally.
local function IsRelevantRelayChannel(channelType)
    if channelType == CHAT_CHANNEL_SAY or channelType == CHAT_CHANNEL_ZONE or channelType == CHAT_CHANNEL_WHISPER then
        return true
    end
    for _, guildChannelType in ipairs(RELAY_GUILD_CHANNEL_TYPES) do
        if channelType == guildChannelType then
            return true
        end
    end
    return false
end

-- Compact one-line snapshot of the local state fields that decide relay accept/reject
-- outcomes, for the relaydebug diagnostic prints below. Not localized, dev-only.
function DE:DescribeRelayDebugState()
    local eventKey = self.state.eventData and self.state.eventData.key or "nil"
    local relayState = self:EnsureRelayState()
    return string.format(
        "status=%s eventData=%s activeSource=%s timerSource=%s",
        tostring(self.state.status),
        tostring(eventKey),
        tostring(self.state.activeSource),
        tostring(relayState.timerSource)
    )
end

function DE:GetRelayRequestCollectionWindowSeconds()
    local seconds = tonumber(self.sv.relayRequestCollectionWindowSeconds)
    if not seconds then
        return RELAY_REQUEST_COLLECTION_WINDOW_SECONDS
    end
    return zo_clamp(seconds, RELAY_REQUEST_COLLECTION_WINDOW_MIN_SECONDS, RELAY_REQUEST_COLLECTION_WINDOW_MAX_SECONDS)
end

-- Keep whisper responses relevant outside supported zones only after our request echo.
function DE:HasPendingRelayRequest()
    local pending = self:EnsureRelayState().pendingRequest
    if not pending or not pending.sentAt then
        return false
    end
    return (GetTimeStamp() - pending.sentAt) < self:GetRelayRequestCollectionWindowSeconds()
end

function DE:OnChatMessageChannel(channelType, fromName, text, isCustomerService, fromDisplayName)
    if not IsRelevantRelayChannel(channelType) then
        return
    end
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    if channelType == CHAT_CHANNEL_WHISPER then
        if not self:HasPendingRelayRequest() then
            return
        end
    elseif not (self.sv.relayReceiveEnabled or self.sv.relayGuildReceiveEnabled or self.sv.relayRequestReceiveEnabled) then
        return
    end
    if not text:find("%[DE%d%a") then
        return
    end

    self:Debug(function()
        return string.format("relaydebug: relay-tagged chat text detected on channel %s from %s | %s", tostring(ChannelTypeToName(channelType)), tostring(fromDisplayName), self:DescribeRelayDebugState())
    end)

    local decoded, decodeReason = self:DecodeRelayMessage(text)
    if not decoded then
        self:Debug(string.format("relaydebug: rejected at decode (%s)", tostring(decodeReason)))
        if self.sv.relayShowInvalidNotice and RELAY_INTEGRITY_FAILURE_REASONS[decodeReason] then
            self:Print(self:T("DE_RELAY_INVALID_MESSAGE_DETECTED"))
        end
        return
    end

    -- Requests lack age/progress fields and therefore use their own handling path.
    if decoded.messageType == RELAY_MESSAGE_TYPE_REQUEST then
        self:HandleIncomingRelayRequest(decoded, channelType, fromDisplayName)
        return
    end

    -- Whispers are accepted only as responses to this player's pending request.
    if channelType == CHAT_CHANNEL_WHISPER then
        self:HandleIncomingRelayRequestResponse(text, fromDisplayName)
        return
    end

    local isValid, configOrReason = self:ValidateRelayMessage(decoded, channelType, fromDisplayName)
    if not isValid then
        self:Debug(function()
            return string.format("relaydebug: rejected at validate (%s) | %s", tostring(configOrReason), self:DescribeRelayDebugState())
        end)
        if self.sv.relayShowInvalidNotice and RELAY_INTEGRITY_FAILURE_REASONS[configOrReason] then
            self:Print(self:T("DE_RELAY_INVALID_MESSAGE_DETECTED"))
        end
        return
    end

    local config = configOrReason
    local relayState = self:EnsureRelayState()
    local dedupKey = fromDisplayName .. "|" .. decoded.sequenceField
    relayState.recentMessages[dedupKey] = GetTimeStamp()
    relayState.lastSequenceBySender[fromDisplayName] = decoded.sequence
    self:CleanupRelayDuplicateCache()

    decoded.receivedAt = GetTimeStamp()
    decoded.fromDisplayName = fromDisplayName

    local channelName = ChannelTypeToName(channelType)
    local isGuildChannel = channelName and channelName:find("^GUILD") ~= nil
    if decoded.messageType == RELAY_MESSAGE_TYPE_ENCOUNTER or isGuildChannel then
        -- Travel-oriented guild shares belong in the persistent list, not a transient dialog.
        self:Debug(string.format("relaydebug: accepted, adding to guild relay list (type=%s)", tostring(decoded.messageType)))
        self:UpsertGuildRelayEntry(decoded, config, ChannelTypeToGuildId(channelType), fromDisplayName)
        return
    end

    self:Debug(string.format("relaydebug: accepted, showing dialog (type=%s)", tostring(decoded.messageType)))

    -- Persist plain message data so /dynet accept survives reloads and short relogs.
    self.sv.relayLastReceived = {
        decoded = decoded,
        channelType = channelType,
        fromDisplayName = fromDisplayName,
    }

    if self.sv.relayAutoAccept then
        self:AcceptRelayMessage(decoded, config)
    else
        self:ShowRelayAcceptDialog(decoded, config)
    end
end

-- Ignore requests unless this player has a matching self-detected state to offer.
function DE:HandleIncomingRelayRequest(decoded, channelType, fromDisplayName)
    local isValid, configOrReason = self:ValidateRelayRequestMessage(decoded, channelType, fromDisplayName)
    if not isValid then
        self:Debug(function()
            return string.format("relaydebug: request rejected at validate (%s) | %s", tostring(configOrReason), self:DescribeRelayDebugState())
        end)
        return
    end

    -- Wildcard guild requests accept any own state; say/zone require an exact timer.
    local config = configOrReason
    local relayState = self:EnsureRelayState()
    local haveMatchingOwnTimer
    if config then
        haveMatchingOwnTimer = self.state.status == self.STATUS_COOLDOWN
            and self.state.eventData == config
            and relayState.timerSource == "self"
    else
        local haveOwnTimer = self.state.status == self.STATUS_COOLDOWN
            and relayState.timerSource == "self"
        local haveOwnActiveEncounter = self.state.status == self.STATUS_ACTIVE
            and not self.state.activeSource
        haveMatchingOwnTimer = haveOwnTimer or haveOwnActiveEncounter
        if haveMatchingOwnTimer then
            config = self.state.eventData
        end
    end
    if not haveMatchingOwnTimer then
        self:Debug(function()
            return string.format("relaydebug: request from %s ignored, no matching own timer | %s", tostring(fromDisplayName), self:DescribeRelayDebugState())
        end)
        return
    end

    -- Throttle each requester independently so one player cannot reopen the dialog repeatedly.
    local senderCooldownKey = "REQ:" .. fromDisplayName
    if self:IsChannelSpamBlocked(senderCooldownKey) then
        return
    end
    self:MarkChannelRelayActivity(senderCooldownKey)

    ZO_Dialogs_ShowDialog("DE_RELAY_REQUEST_RECEIVED", {
        config = config,
        fromDisplayName = fromDisplayName,
        -- Reuse the locally received channel type to avoid cross-account guild-slot drift.
        channelType = channelType,
    })
end

-- Say/zone responses resolve one local instance; guild responses populate the persistent list.
function DE:HandleIncomingRelayRequestResponse(text, fromDisplayName)
    local decoded, decodeReason = self:DecodeRelayMessage(text)
    if not decoded or (decoded.messageType ~= RELAY_MESSAGE_TYPE_TIMER and decoded.messageType ~= RELAY_MESSAGE_TYPE_ENCOUNTER) then
        if decodeReason then
            self:Debug(string.format("relaydebug: whisper response rejected at decode (%s)", tostring(decodeReason)))
        end
        return
    end

    local relayState = self:EnsureRelayState()
    local pending = relayState.pendingRequest
    if not pending then
        return
    end
    -- A guild-wildcard request (pending.relayCode == RELAY_REQUEST_WILDCARD)
    -- accepts a response for ANY encounter; a say/zone request still only
    -- matches its own specific relayCode.
    if pending.relayCode ~= RELAY_REQUEST_WILDCARD and decoded.relayCode ~= pending.relayCode then
        return
    end

    local isValid, configOrReason
    if decoded.messageType == RELAY_MESSAGE_TYPE_ENCOUNTER then
        isValid, configOrReason = self:ValidateRelayEncounterMessage(decoded, CHAT_CHANNEL_WHISPER, fromDisplayName, true, true)
    else
        isValid, configOrReason = self:ValidateRelayTimerMessage(decoded, CHAT_CHANNEL_WHISPER, fromDisplayName, true, true)
    end
    if not isValid then
        self:Debug(function()
            return string.format("relaydebug: whisper response rejected at validate (%s) | %s", tostring(configOrReason), self:DescribeRelayDebugState())
        end)
        return
    end

    decoded.receivedAt = GetTimeStamp()
    decoded.fromDisplayName = fromDisplayName

    if not pending.isGuildChannel then
        -- The first say/zone response is definitive; ignore later replies silently.
        if self:AcceptRelayMessage(decoded, configOrReason) then
            relayState.pendingRequest = nil
        end
        return
    end

    self:UpsertGuildRelayEntry(decoded, configOrReason, pending.guildId, fromDisplayName)
end

-- Revalidate stored say/zone messages without treating the same message as a
-- duplicate; acceptance still reapplies the current priority rules.
function DE:ReshowLastRelayDialog()
    local last = self.sv.relayLastReceived
    if not last or not last.decoded or not last.decoded.receivedAt
        or (GetTimeStamp() - last.decoded.receivedAt) > RELAY_LAST_RECEIVED_MAX_AGE_SECONDS then
        self:Print(self:T("DE_RELAY_LINK_EXPIRED_OR_INVALID"))
        return
    end

    local isValid, configOrReason = self:ValidateRelayMessage(last.decoded, last.channelType, last.fromDisplayName, true, true)
    if not isValid then
        self:Debug(function()
            return string.format("relaydebug: /dynet accept rejected at re-validate (%s) | %s", tostring(configOrReason), self:DescribeRelayDebugState())
        end)
        self:Print(self:T("DE_RELAY_LINK_EXPIRED_OR_INVALID"))
        return
    end

    self:Debug(string.format("relaydebug: /dynet accept re-showing dialog (type=%s)", tostring(last.decoded.messageType)))

    self:ShowRelayAcceptDialog(last.decoded, configOrReason)
end

local RELAY_SEND_FAILURE_STRING_IDS = {
    ["unsupported-channel"] = "DE_RELAY_SEND_FAILED_UNSUPPORTED_CHANNEL",
    ["unknown-encounter"] = "DE_RELAY_SEND_FAILED_UNKNOWN_ENCOUNTER",
    ["no-timer"] = "DE_RELAY_SEND_FAILED_NO_TIMER",
    ["not-own-timer"] = "DE_RELAY_SEND_FAILED_NOT_OWN_TIMER",
    ["no-encounter"] = "DE_RELAY_SEND_FAILED_NO_ENCOUNTER",
    ["not-own-encounter"] = "DE_RELAY_SEND_FAILED_NOT_OWN_ENCOUNTER",
}

-- Persist acceptance by notice version; cancellation deliberately drops the pending send.
function DE:EnsureRelayCodeOfConductAccepted(onSend)
    if (tonumber(self.sv.relayCodeOfConductAcceptedVersion) or 0) >= RELAY_CODE_OF_CONDUCT_VERSION then
        onSend()
        return
    end
    -- ZO_Dialogs_ShowDialog exposes this table as dialog.data to button callbacks.
    local data = {
        onSend = onSend,
        relayCodeOfConductSecondsLeft = RELAY_CODE_OF_CONDUCT_WAIT_SECONDS,
        relayCodeOfConductCountdownDone = false,
    }
    self:StartRelayCodeOfConductCountdown(data)
    ZO_Dialogs_ShowDialog("DE_RELAY_CODE_OF_CONDUCT", data)
end

function DE:SendRelayTimerMessage(config, channelType)
    self:EnsureRelayCodeOfConductAccepted(function()
        self:SendRelayTimerMessageNow(config, channelType)
    end)
end

function DE:SendRelayTimerMessageNow(config, channelType)
    local text, reasonKey = self:EncodeRelayTimerMessage(config, channelType)
    if not text then
        if reasonKey == "channel-cooldown" then
            local _, remainingSeconds = self:IsChannelSpamBlocked(ChannelTypeToName(channelType))
            self:Print(self:T("DE_RELAY_SEND_FAILED_CHANNEL_COOLDOWN", zo_ceil(remainingSeconds or 0)))
        else
            local stringId = RELAY_SEND_FAILURE_STRING_IDS[reasonKey] or "DE_RELAY_SEND_FAILED_NO_TIMER"
            self:Print(self:T(stringId))
        end
        return false, reasonKey
    end

    self:MarkChannelRelayActivity(ChannelTypeToName(channelType))
    ZO_GetChatSystem():StartTextEntry(text, channelType)
    return true
end

-- Whispers a response to an incoming timer request. Goes through the same
-- code-of-conduct gate as any other share (see EnsureRelayCodeOfConductAccepted),
-- since a whispered timer is still "sharing" in the sense that notice covers.
function DE:SendRelayWhisperTimerResponse(config, targetDisplayName)
    self:EnsureRelayCodeOfConductAccepted(function()
        self:SendRelayWhisperTimerResponseNow(config, targetDisplayName)
    end)
end

function DE:SendRelayWhisperTimerResponseNow(config, targetDisplayName)
    local text, reasonKey = self:EncodeRelayTimerMessage(config, CHAT_CHANNEL_WHISPER, targetDisplayName)
    if not text then
        if reasonKey == "channel-cooldown" then
            local _, remainingSeconds = self:IsChannelSpamBlocked(ChannelTypeToName(CHAT_CHANNEL_WHISPER, targetDisplayName))
            self:Print(self:T("DE_RELAY_SEND_FAILED_CHANNEL_COOLDOWN", zo_ceil(remainingSeconds or 0)))
        else
            local stringId = RELAY_SEND_FAILURE_STRING_IDS[reasonKey] or "DE_RELAY_SEND_FAILED_NO_TIMER"
            self:Print(self:T(stringId))
        end
        return false, reasonKey
    end

    self:MarkChannelRelayActivity(ChannelTypeToName(CHAT_CHANNEL_WHISPER, targetDisplayName))
    ZO_GetChatSystem():StartTextEntry(text, CHAT_CHANNEL_WHISPER, targetDisplayName)
    return true
end

function DE:SendRelayEncounterMessage(config, channelType, target)
    self:EnsureRelayCodeOfConductAccepted(function()
        self:SendRelayEncounterMessageNow(config, channelType, target)
    end)
end

function DE:SendRelayEncounterMessageNow(config, channelType, target)
    local text, reasonKey = self:EncodeRelayEncounterMessage(config, channelType, target)
    if not text then
        if reasonKey == "channel-cooldown" then
            local _, remainingSeconds = self:IsChannelSpamBlocked(ChannelTypeToName(channelType, target))
            self:Print(self:T("DE_RELAY_SEND_FAILED_CHANNEL_COOLDOWN", zo_ceil(remainingSeconds or 0)))
        else
            local stringId = RELAY_SEND_FAILURE_STRING_IDS[reasonKey] or "DE_RELAY_SEND_FAILED_NO_ENCOUNTER"
            self:Print(self:T(stringId))
        end
        return false, reasonKey
    end

    self:MarkChannelRelayActivity(ChannelTypeToName(channelType, target))
    ZO_GetChatSystem():StartTextEntry(text, channelType, target)
    return true
end

-- Start response collection only after the request appears as a sent chat echo.
function DE:SendRelayTimerRequest(config, channelType)
    self:EnsureRelayCodeOfConductAccepted(function()
        self:SendRelayTimerRequestNow(config, channelType)
    end)
end

function DE:SendRelayTimerRequestNow(config, channelType)
    local text, reasonKeyOrSequenceField = self:EncodeRelayTimerRequest(config, channelType)
    if not text then
        local reasonKey = reasonKeyOrSequenceField
        if reasonKey == "channel-cooldown" then
            local _, remainingSeconds = self:IsChannelSpamBlocked(ChannelTypeToName(channelType))
            self:Print(self:T("DE_RELAY_SEND_FAILED_CHANNEL_COOLDOWN", zo_ceil(remainingSeconds or 0)))
        else
            local stringId = RELAY_SEND_FAILURE_STRING_IDS[reasonKey] or "DE_RELAY_REQUEST_SEND_FAILED"
            self:Print(self:T(stringId))
        end
        return false, reasonKey
    end
    local sequenceField = reasonKeyOrSequenceField

    self:MarkChannelRelayActivity(ChannelTypeToName(channelType))
    ZO_GetChatSystem():StartTextEntry(text, channelType)

    local relayState = self:EnsureRelayState()
    local isGuildChannel = ChannelTypeToName(channelType):find("^GUILD") ~= nil
    relayState.pendingRequest = {
        relayCode = isGuildChannel and RELAY_REQUEST_WILDCARD or config.relayCode,
        sequenceField = sequenceField,
        sentAt = nil,
        isGuildChannel = isGuildChannel,
        -- Preserve the guild because whispered responses carry no channel metadata.
        guildId = isGuildChannel and ChannelTypeToGuildId(channelType) or nil,
    }

    self:Print(self:T("DE_RELAY_REQUEST_SENT"))
    return true
end

-- Start the guild response window only after the request's own chat echo confirms sending.
function DE:ArmRelayPendingRequest()
    local relayState = self:EnsureRelayState()
    local pending = relayState.pendingRequest
    if not pending or pending.sentAt then
        return
    end
    pending.sentAt = GetTimeStamp()
end

function DE:ShowRelayChannelChoiceDialog()
    if not self.state.eventData
        or self.state.status ~= self.STATUS_COOLDOWN
        or self:EnsureRelayState().timerSource ~= "self" then
        return
    end
    ZO_Dialogs_ShowDialog("DE_RELAY_CHOOSE_CHANNEL", {
        config = self.state.eventData,
    })
end

function DE:ShowRelayEncounterChannelChoiceDialog()
    if not self.state.eventData
        or self.state.status ~= self.STATUS_ACTIVE
        or self.state.activeSource then
        return
    end
    ZO_Dialogs_ShowDialog("DE_RELAY_CHOOSE_GUILD_CHANNEL", {
        config = self.state.eventData,
    })
end

function DE:ShowRelayAcceptDialog(decoded, config)
    ZO_Dialogs_ShowDialog("DE_RELAY_ACCEPT_TIMER", {
        decoded = decoded,
        config = config,
    })
end

local function GuildRelayEntryKey(fromDisplayName, relayCode)
    return tostring(fromDisplayName) .. "|" .. tostring(relayCode)
end

-- Cooldown reports within this respawn-time tolerance represent one instance.
local GUILD_RELAY_INSTANCE_TIME_TOLERANCE_SECONDS = 4

-- Active discovery times are not reliable instance signatures, so active reports
-- for one config merge; cooldowns merge only by matching server-derived respawn time.
local function FindExistingGuildRelayInstanceKey(entries, config, entryType, newLocalRespawnAt)
    local bestKey, bestDiff
    for key, entry in pairs(entries) do
        if entry.config == config and entry.entryType == entryType then
            if entryType == "active" then
                return key
            end
            local diff = math.abs((entry.localRespawnAt or 0) - (newLocalRespawnAt or 0))
            if not bestDiff or diff < bestDiff then
                bestDiff = diff
                bestKey = key
            end
        end
    end
    if bestKey and bestDiff and bestDiff <= GUILD_RELAY_INSTANCE_TIME_TOLERANCE_SECONDS then
        return bestKey
    end
    return nil
end

-- Prefer the sender's row, then merge a matching instance reported by another sender.
function DE:UpsertGuildRelayEntry(decoded, config, guildId, fromDisplayName)
    local entries = self.state.guildRelayEntries
    local key = GuildRelayEntryKey(fromDisplayName, decoded.relayCode)

    local elapsedSinceReceipt = zo_max(0, GetTimeStamp() - (decoded.receivedAt or GetTimeStamp()))
    local totalEventAge = (decoded.ageUnits * RELAY_AGE_UNIT_SECONDS) + elapsedSinceReceipt
    local entryType = decoded.messageType == RELAY_MESSAGE_TYPE_ENCOUNTER and "active" or "cooldown"
    local newLocalRespawnAt
    if entryType == "cooldown" then
        newLocalRespawnAt = GetTimeStamp() - totalEventAge + self:GetRespawnTiming(config).expectedSeconds
    end

    local entry = entries[key]
    if not entry then
        local mergeKey = FindExistingGuildRelayInstanceKey(entries, config, entryType, newLocalRespawnAt)
        if mergeKey then
            entry = entries[mergeKey]
            entries[mergeKey] = nil
        else
            entry = {}
        end
        entries[key] = entry
    end

    entry.fromDisplayName = fromDisplayName
    entry.config = config
    entry.guildId = guildId
    entry.zoneId = config.zoneId
    entry.lastUpdatedAt = GetTimeStamp()
    entry.entryType = entryType

    if entryType == "active" then
        local progressPercent = ((decoded.progressBucket + 0.5) / RELAY_PROGRESS_BUCKET_COUNT) * 100
        entry.activeStartedAt = GetTimeStamp() - totalEventAge
        entry.currentProgress = progressPercent
        entry.maxProgress = 100
        entry.localRespawnAt = nil
        -- Shared and estimated active entries use different text and expiry windows.
        entry.activeSource = "share"
    else
        entry.localRespawnAt = newLocalRespawnAt
        entry.activeStartedAt = nil
        entry.currentProgress = nil
        entry.maxProgress = nil
        entry.activeSource = nil
    end

    if self.GuildRelayWindow then
        self.GuildRelayWindow:Refresh()
    end
end

function DE:RemoveGuildRelayEntry(fromDisplayName, relayCode)
    local key = GuildRelayEntryKey(fromDisplayName, relayCode)
    if not self.state.guildRelayEntries[key] then
        return
    end
    self.state.guildRelayEntries[key] = nil
    if self.GuildRelayWindow then
        self.GuildRelayWindow:Refresh()
    end
end

-- ESO has no CanJumpToGuildMember equivalent; online and zone checks are the proxy.
function DE:CheckGuildRelayMemberReachable(entry)
    if not entry.guildId then
        return false, "no-guild-id"
    end
    local memberIndex = GetGuildMemberIndexFromDisplayName(entry.guildId, entry.fromDisplayName)
    if not memberIndex then
        return false, "member-not-found"
    end

    local _, _, _, playerStatus = GetGuildMemberInfo(entry.guildId, memberIndex)
    if playerStatus == PLAYER_STATUS_OFFLINE then
        return false, "offline"
    end

    local _, _, _, _, _, _, _, currentZoneId = GetGuildMemberCharacterInfo(entry.guildId, memberIndex)
    if currentZoneId and entry.zoneId and currentZoneId ~= entry.zoneId then
        return false, "zone-changed"
    end

    return true
end

-- Preserve the row and defer state takeover until travel reaches the reported zone;
-- a local scan remains authoritative and failed travel leaves the share reusable.
function DE:AcceptGuildRelayEntry(entry)
    -- Never start a second guild jump while the first one is unresolved.
    if self:IsRelayTravelPending() then
        self:Print(self:T("DE_RELAY_WINDOW_JUMP_IN_PROGRESS"))
        return false
    end

    local reachable, failureReason = self:CheckGuildRelayMemberReachable(entry)
    if not reachable then
        self:Print(self:T("DE_RELAY_WINDOW_MEMBER_UNREACHABLE", entry.fromDisplayName))
        self:RemoveGuildRelayEntry(entry.fromDisplayName, entry.config.relayCode)
        self:Debug(string.format("relaydebug: guild relay jump aborted, member unreachable (%s)", tostring(failureReason)))
        return false
    end

    if not CanLeaveCurrentLocationViaTeleport() then
        self:Print(self:T("DE_RELAY_ENCOUNTER_PORT_FAILED"))
        return false
    end

    local relayState = self:EnsureRelayState()
    relayState.pendingGuildRelayAccept = entry

    -- EVENT_SOCIAL_ERROR is global, so discard stale errors before this jump.
    self.relaySocialErrorPending = nil

    -- Must be set before JumpToGuildMember - the resulting EVENT_ZONE_CHANGED
    -- can fire before the call below even returns.
    self:MarkRelayTravelPending()
    JumpToGuildMember(entry.fromDisplayName)

    zo_callLater(function()
        if self.relaySocialErrorPending then
            self.relaySocialErrorPending = nil
            -- A failed jump must not be applied by a later unrelated zone change.
            relayState.pendingGuildRelayAccept = nil
            self:ClearRelayTravelPending()
            self:Print(self:T("DE_RELAY_ENCOUNTER_PORT_FAILED"))
        end
    end, 1500)

    self:Print(self:T(entry.entryType == "active" and "DE_RELAY_ENCOUNTER_ACCEPTED" or "DE_RELAY_GUILD_TIMER_ACCEPTED", entry.fromDisplayName))
    return true
end

-- Apply the relay state only after arrival in the reported zone is confirmed.
function DE:ApplyPendingGuildRelayAccept(entry)
    local relayState = self:EnsureRelayState()

    if entry.entryType == "active" then
        self.state.eventData = entry.config
        self.state.status = self.STATUS_ACTIVE
        self.state.activeStartedAt = entry.activeStartedAt
        self.state.currentProgress = entry.currentProgress
        self.state.maxProgress = entry.maxProgress
        self.state.activeSource = "relay:" .. tostring(entry.fromDisplayName)
        self.state.stepRun = nil
        self.state.currentStepDefId = nil
    else
        self.state.eventData = entry.config
        self.state.status = self.STATUS_COOLDOWN
        self.state.cooldownStartedAt = entry.localRespawnAt - self:GetRespawnTiming(entry.config).expectedSeconds
        self.state.cooldownStartExact = false
        self.state.cooldownSource = "relay:" .. tostring(entry.fromDisplayName)
        relayState.timerSource = "received"
        self:RecalculateActiveCooldown()
    end

    self:RecordDiagnosticSnapshot(entry.entryType == "active" and "relay-accept-encounter" or "relay-accept-guild-timer", true)

    -- Remove the share only after successful application.
    self:RemoveGuildRelayEntry(entry.fromDisplayName, entry.config.relayCode)
end

-- Promote cooldowns on the one-second UI cadence; slower reachability and expiry
-- checks stay separate. Shared and estimated active entries use distinct lifetimes.
function DE:PromoteExpiredGuildRelayCooldowns()
    local entries = self.state.guildRelayEntries
    local now = GetTimeStamp()
    local changed = false

    for _, entry in pairs(entries) do
        if entry.entryType == "cooldown" then
            local overdueBy = now - (entry.localRespawnAt or now)
            if overdueBy > 0 then
                entry.entryType = "active"
                entry.activeSource = "estimated"
                entry.activeStartedAt = entry.localRespawnAt
                entry.currentProgress = nil
                entry.maxProgress = nil
                entry.localRespawnAt = nil
                -- The estimated-active lifetime begins at promotion, not at the original share.
                entry.lastUpdatedAt = now
                changed = true
                self:Debug(string.format("relaydebug: guild relay entry for %s promoted to estimated-active (cooldown expired)", tostring(entry.fromDisplayName)))
            end
        end
    end

    if changed and self.GuildRelayWindow then
        self.GuildRelayWindow:Refresh()
    end
    return changed
end

function DE:CheckGuildRelayEntriesLiveness()
    local entries = self.state.guildRelayEntries
    local now = GetTimeStamp()
    local changed = self:PromoteExpiredGuildRelayCooldowns()

    for key, entry in pairs(entries) do
        -- Synthetic preview/debug entries have no guild member to validate.
        local reachable = (entry.isPreview or entry.isDebugFake) or self:CheckGuildRelayMemberReachable(entry)
        if not reachable then
            entries[key] = nil
            changed = true
            self:Debug(string.format("relaydebug: guild relay entry for %s removed by liveness check (unreachable)", tostring(entry.fromDisplayName)))
        elseif entry.entryType == "active" then
            local maxAgeSeconds = entry.activeSource == "estimated"
                and (self.sv.relayWindowActiveEstimatedMaxAgeSeconds or self.defaults.relayWindowActiveEstimatedMaxAgeSeconds)
                or (self.sv.relayWindowActiveShareMaxAgeSeconds or self.defaults.relayWindowActiveShareMaxAgeSeconds)
            -- Expiry starts at the latest share or promotion, not the encounter start.
            local ageSeconds = now - (entry.lastUpdatedAt or now)
            if ageSeconds > maxAgeSeconds then
                entries[key] = nil
                changed = true
                self:Debug(string.format("relaydebug: guild relay entry for %s removed by liveness check (active entry stale, source=%s)", tostring(entry.fromDisplayName), tostring(entry.activeSource)))
            end
        end
    end

    if changed and self.GuildRelayWindow then
        self.GuildRelayWindow:Refresh()
    end
end

function DE:StartGuildRelayLivenessTick()
    self:StopGuildRelayLivenessTick()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    local intervalMs = zo_max(5, tonumber(self.sv.relayWindowCheckIntervalSeconds) or 15) * 1000
    EVENT_MANAGER:RegisterForUpdate(self.name .. "_GuildRelayLivenessTick", intervalMs, function()
        self:CheckGuildRelayEntriesLiveness()
    end)
end

function DE:StopGuildRelayLivenessTick()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_GuildRelayLivenessTick")
end

function DE:AcceptRelayMessage(decoded, config)
    local relayState = self:EnsureRelayState()
    if self.state.status == self.STATUS_COOLDOWN and relayState.timerSource ~= nil then
        self:Print(self:T("DE_RELAY_OWN_TIMER_PRIORITY"))
        return false
    end

    local elapsedSinceReceipt = zo_max(0, GetTimeStamp() - (decoded.receivedAt or GetTimeStamp()))
    local totalEventAge = (decoded.ageUnits * RELAY_AGE_UNIT_SECONDS) + elapsedSinceReceipt

    self.state.eventData = config
    self.state.status = self.STATUS_COOLDOWN
    self.state.cooldownStartedAt = GetTimeStamp() - totalEventAge
    self.state.cooldownStartExact = false
    self.state.cooldownSource = "relay:" .. tostring(decoded.fromDisplayName)
    relayState.timerSource = "received"

    self:RecalculateActiveCooldown()
    self:RecordDiagnosticSnapshot("relay-accept", true)
    self:Print(self:T("DE_RELAY_ACCEPTED", decoded.fromDisplayName))
    return true
end

function DE:OnSocialError(eventCode, errorCode)
    if errorCode and errorCode ~= 0 then
        self.relaySocialErrorPending = true
    end
end

-- One fixed update is sufficient because only one notice dialog can exist.
local RELAY_CODE_OF_CONDUCT_COUNTDOWN_UPDATE_NAME = "DynamicEncounterTrackerRelayCodeOfConductCountdown"

-- Plain ZO_TwoButtonDialog setup callbacks do not run; start this countdown
-- before showing the dialog (verified in esoui/libraries/zo_dialog/zo_dialog.lua).
function DE:StartRelayCodeOfConductCountdown(data)
    if data.infoOnly then
        data.relayCodeOfConductCountdownDone = true
        return
    end
    EVENT_MANAGER:UnregisterForUpdate(RELAY_CODE_OF_CONDUCT_COUNTDOWN_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(RELAY_CODE_OF_CONDUCT_COUNTDOWN_UPDATE_NAME, 1000, function()
        data.relayCodeOfConductSecondsLeft = data.relayCodeOfConductSecondsLeft - 1
        if data.relayCodeOfConductSecondsLeft <= 0 then
            EVENT_MANAGER:UnregisterForUpdate(RELAY_CODE_OF_CONDUCT_COUNTDOWN_UPDATE_NAME)
            data.relayCodeOfConductCountdownDone = true
        end
        local dialog = ZO_Dialogs_FindDialog("DE_RELAY_CODE_OF_CONDUCT")
        if dialog then
            -- ESO updates enabled state and button text through separate dialog APIs.
            ZO_Dialogs_UpdateButtonVisibilityAndEnabledState(dialog, 1)
            ZO_Dialogs_RefreshButtonTexts(dialog)
        end
    end)
end

function Relay:Initialize()
    -- canQueue: a reply button (e.g. DE_RELAY_REQUEST_RECEIVED's "same
    -- channel" default) can trigger this from inside another dialog's still-
    -- open callback - ESO invokes the callback before releasing that dialog,
    -- so ShowDialog here silently did nothing without queuing (live report:
    -- clicking "Reply" with the code of conduct not yet accepted appeared to
    -- do nothing).
    ZO_Dialogs_RegisterCustomDialog("DE_RELAY_CODE_OF_CONDUCT", {
        canQueue = true,
        title = {
            text = DE:T("DE_RELAY_CODE_OF_CONDUCT_TITLE"),
        },
        mainText = {
            text = DE:T("DE_RELAY_CODE_OF_CONDUCT_TEXT"),
        },
        finishedCallback = function(dialog)
            EVENT_MANAGER:UnregisterForUpdate(RELAY_CODE_OF_CONDUCT_COUNTDOWN_UPDATE_NAME)
        end,
        buttons = {
            [1] = {
                -- Keep the disabled button visible so its countdown communicates the wait.
                text = function(dialog)
                    if dialog.data.infoOnly or dialog.data.relayCodeOfConductCountdownDone then
                        return DE:T("DE_RELAY_CODE_OF_CONDUCT_ACCEPT")
                    end
                    return DE:T("DE_RELAY_CODE_OF_CONDUCT_ACCEPT_FMT", dialog.data.relayCodeOfConductSecondsLeft or RELAY_CODE_OF_CONDUCT_WAIT_SECONDS)
                end,
                enabled = function(dialog)
                    return dialog.data.infoOnly or dialog.data.relayCodeOfConductCountdownDone or false
                end,
                callback = function(dialog)
                    DE.sv.relayCodeOfConductAcceptedVersion = RELAY_CODE_OF_CONDUCT_VERSION
                    if dialog.data.onSend then
                        dialog.data.onSend()
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog("DE_RELAY_ACCEPT_TIMER", {
        title = {
            text = DE:T("DE_RELAY_DIALOG_TITLE"),
        },
        mainText = {
            text = function(dialog)
                local decoded = dialog.data.decoded
                local config = dialog.data.config
                local elapsedSinceReceipt = zo_max(0, GetTimeStamp() - (decoded.receivedAt or GetTimeStamp()))
                local totalEventAge = (decoded.ageUnits * RELAY_AGE_UNIT_SECONDS) + elapsedSinceReceipt
                local timing = DE:GetRespawnTiming(config)
                local remainingSeconds = zo_max(0, timing.expectedSeconds - totalEventAge)
                local zoneName = zo_strformat(SI_ZONE_NAME, GetZoneNameById(config.zoneId))
                local readableTime = DE:FormatRespawnTime(remainingSeconds)
                return DE:T("DE_RELAY_DIALOG_TEXT_FMT", zoneName, readableTime, decoded.fromDisplayName)
            end,
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    DE:AcceptRelayMessage(dialog.data.decoded, dialog.data.config)
                end,
            },
            [2] = {
                text = SI_DIALOG_DECLINE,
            },
        },
    })

    -- Use two standard dialogs because custom XML controls may not exist at addon load.
    -- Same-channel replies reuse the locally received channel type.
    local function ReplyInSameChannel(data)
        local isOwnActiveEncounter = DE.state.status == DE.STATUS_ACTIVE and not DE.state.activeSource
        if isOwnActiveEncounter then
            DE:SendRelayEncounterMessage(DE.state.eventData, data.channelType)
        else
            DE:SendRelayTimerMessage(data.config, data.channelType)
        end
    end

    -- Wildcard guild requests reply with whichever own state is currently active.
    local function ReplyByWhisper(data)
        local isOwnActiveEncounter = DE.state.status == DE.STATUS_ACTIVE and not DE.state.activeSource
        if isOwnActiveEncounter then
            DE:SendRelayEncounterMessage(DE.state.eventData, CHAT_CHANNEL_WHISPER, data.fromDisplayName)
        else
            DE:SendRelayWhisperTimerResponse(data.config, data.fromDisplayName)
        end
    end

    ZO_Dialogs_RegisterCustomDialog("DE_RELAY_REQUEST_RECEIVED", {
        title = {
            text = DE:T("DE_RELAY_REQUEST_RECEIVED_TITLE"),
        },
        mainText = {
            text = function(dialog)
                local config = dialog.data.config
                local zoneName = zo_strformat(SI_ZONE_NAME, GetZoneNameById(config.zoneId))
                local baseText = DE:T("DE_RELAY_REQUEST_RECEIVED_TEXT_FMT", dialog.data.fromDisplayName, zoneName)

                -- State non-interactive defaults; "ask" is explained by the next dialog.
                local replyChannel = DE.sv.relayRequestReplyChannel or "ask"
                if replyChannel == "whisper" then
                    return baseText .. "\n\n" .. DE:T("DE_RELAY_REQUEST_REPLY_DEFAULT_WHISPER_NOTICE")
                elseif replyChannel == "same" then
                    return baseText .. "\n\n" .. DE:T("DE_RELAY_REQUEST_REPLY_DEFAULT_SAME_NOTICE")
                end
                return baseText
            end,
        },
        buttons = {
            [1] = {
                text = DE:T("DE_RELAY_REQUEST_REPLY_BUTTON"),
                callback = function(dialog)
                    local replyChannel = DE.sv.relayRequestReplyChannel or "ask"
                    if replyChannel == "whisper" then
                        ReplyByWhisper(dialog.data)
                    elseif replyChannel == "same" then
                        ReplyInSameChannel(dialog.data)
                    else
                        ZO_Dialogs_ShowDialog("DE_RELAY_REQUEST_REPLY_METHOD", dialog.data)
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_DECLINE,
            },
        },
    })

    -- Queue step two because ESO invokes the callback before releasing step one.
    ZO_Dialogs_RegisterCustomDialog("DE_RELAY_REQUEST_REPLY_METHOD", {
        canQueue = true,
        title = {
            text = DE:T("DE_RELAY_REQUEST_RECEIVED_TITLE"),
        },
        mainText = {
            text = function(dialog)
                return DE:T("DE_RELAY_REQUEST_REPLY_METHOD_TEXT", dialog.data.fromDisplayName)
            end,
        },
        buttons = {
            [1] = {
                text = function(dialog)
                    local channelName = ChannelTypeToName(dialog.data.channelType)
                    if channelName and channelName:find("^GUILD") then
                        return DE:T("DE_RELAY_REQUEST_REPLY_GUILD_BUTTON")
                    end
                    return DE:T("DE_RELAY_REQUEST_REPLY_CHANNEL_BUTTON")
                end,
                callback = function(dialog)
                    ReplyInSameChannel(dialog.data)
                end,
            },
            [2] = {
                text = DE:T("DE_RELAY_REQUEST_WHISPER_BUTTON"),
                callback = function(dialog)
                    ReplyByWhisper(dialog.data)
                end,
            },
        },
    })

    EVENT_MANAGER:RegisterForEvent("DynamicEncounterTrackerRelaySocialError", EVENT_SOCIAL_ERROR, function(...)
        DE:OnSocialError(...)
    end)
end

local function ParseRelayChannelWord(channelWord)
    channelWord = zo_strlower(channelWord)
    if channelWord == "say" then
        return CHAT_CHANNEL_SAY
    elseif channelWord == "zone" then
        return CHAT_CHANNEL_ZONE
    end
    local guildIndex = channelWord:match("^guild(%d)$")
    guildIndex = guildIndex and tonumber(guildIndex)
    if guildIndex and guildIndex >= 1 and guildIndex <= 5 then
        return RELAY_GUILD_CHANNEL_TYPES[guildIndex]
    end
    return nil
end

function Relay:HandleSlashCommand(command)
    if command == "accept" then
        DE:ReshowLastRelayDialog()
        return true
    end

    local requestChannelWord = command:match("^request%s+(%w+)$")
    if requestChannelWord then
        local channelType = ParseRelayChannelWord(requestChannelWord)
        if not channelType then
            return false
        end
        local _, _, currentConfigs = DE:GetCurrentZoneData()
        local config = type(currentConfigs) == "table" and currentConfigs[1] or nil
        local isGuildChannel = ChannelTypeToName(channelType):find("^GUILD") ~= nil
        if not config and not isGuildChannel then
            -- Say/zone requests still need a real, current encounter (see
            -- EncodeRelayTimerRequest) - guild requests go out zone/encounter-
            -- independent via the wildcard relayCode even with config = nil.
            DE:Print(DE:T("DE_RELAY_REQUEST_SEND_FAILED"))
            return true
        end

        -- Local requests are pointless with an own timer; guild requests can still help others.
        if config and not isGuildChannel then
            local relayState = DE:EnsureRelayState()
            local ownTimerActive = DE.state.status == DE.STATUS_COOLDOWN and relayState.timerSource == "self"
            local ownEncounterActive = DE.state.status == DE.STATUS_ACTIVE and not DE.state.activeSource
            if ownTimerActive or ownEncounterActive then
                DE:Print(DE:T("DE_RELAY_REQUEST_SEND_FAILED_OWN_ACTIVE"))
                return true
            end
        end

        DE:SendRelayTimerRequest(config, channelType)
        return true
    end

    if command == "reset" then
        DE:ResetOwnRelayTimer()
        return true
    end

    if command == "border" then
        if DE.GuildRelayWindow then
            DE.GuildRelayWindow:ToggleBorder()
        end
        return true
    end

    local channelWord = command:match("^share%s+(%w+)$")
    if not channelWord then
        return false
    end

    local channelType = ParseRelayChannelWord(channelWord)
    if not channelType then
        return false
    end

    if channelWord:lower():find("^guild") then
        -- Guild channels can carry either an active encounter or a respawn
        -- timer share, depending on what the player currently has running.
        if DE.state.status == DE.STATUS_ACTIVE then
            DE:SendRelayEncounterMessage(DE.state.eventData, channelType)
        else
            DE:SendRelayTimerMessage(DE.state.eventData, channelType)
        end
        return true
    end

    DE:SendRelayTimerMessage(DE.state.eventData, channelType)
    return true
end

function Relay:PrintCommandHelp()
    DE:Print(DE:T("DE_SLASH_COMMANDS_RELAY"))
end

DE:RegisterModule("relay", Relay)
