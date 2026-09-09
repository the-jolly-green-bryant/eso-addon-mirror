local TT = TamrielicTongues

-- One Knowledge state per language, owned and persisted by the caller. Load
-- after the catalog and Knowledge. No chat/UI or clock APIs.
-- This limits ordinary repetition, not a user editing saves, clocks or Lua.
-- Configuration is trusted application policy, not received message data.
local P = {
    Config = {
        vocabularyXP = 1, grammarXP = 1, messageCap = 4,
        dailyVocabularyCap = 40, dailyGrammarCap = 40,
        minimumVocabularyDiversity = 2,
        unitCooldown = 3600, contentCooldown = 86400,
        historyLimit = 512, maxFingerprintBytes = 4096,
        studyGrantCap = 20, practiceGrantCap = 10,
        activityCooldown = 86400, activityDailyCap = 20,
    },
}
TT.Progression = P
local lessons, exercises = {}, {}
local DAY = 86400

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
local function amount(n)
    return finite(n) and n >= 0 and n == math.floor(n)
end
local function validTime(now)
    return finite(now) and now >= 0 and now <= 9007199254740991 - DAY
end
local function keys(map)
    local result = {}
    for id in pairs(map) do result[#result + 1] = id end
    table.sort(result)
    return result
end
local function summary(reason)
    return { vocabularyXP = 0, grammarXP = 0, vocabulary = {}, grammar = {}, reason = reason }
end
local function requirement(axis, id)
    if type(id) ~= "string" then return nil end
    if axis == "grammar" then return TT.CanonicalCatalog.GrammarRequirements[id] end
    local entry = TT.CanonicalCatalog:GetEntry(id)
    return entry and entry.requirement
end
local function units(axis, map)
    local result = {}
    if type(map) ~= "table" then return result end
    for id, req in pairs(map) do
        local expected = requirement(axis, id)
        if expected ~= nil and expected == req then result[id] = req end
    end
    return keys(result)
end
-- Validate before any read that assumes the persisted schema, including before
-- pruning expired records. Never repair/reset corrupt or newer data here: the
-- persistence layer must migrate it explicitly. A lowered history limit also fails closed, even
-- for expired records, rather than silently discarding saved protections.
local function exposureReason(self, e)
    if e == nil then return nil end
    if type(e) ~= "table" then return "malformed-exposure" end
    if e.version ~= 1 then
        return amount(e.version) and e.version > 1 and "unsupported-exposure-version" or "malformed-exposure"
    end
    if not validTime(e.highWater) or not amount(e.day) or e.day ~= math.floor(e.highWater / DAY)
        or not amount(e.vocabularyXP) or e.vocabularyXP > 10000
        or not amount(e.grammarXP) or e.grammarXP > 10000
        or type(e.records) ~= "table" then return "malformed-exposure" end
    local count = 0
    for key, record in pairs(e.records) do
        count = count + 1
        if count > self.Config.historyLimit then return "exposure-history-over-capacity" end
        if type(key) ~= "string" or type(record) ~= "table"
            or not finite(record.expires) or record.expires < 0 then return "malformed-exposure" end
        local kind, id = key:match("^([^:]+):(.+)$")
        local activity = kind == "lesson" or kind == "exercise"
        local limit = kind == "content" and self.Config.maxFingerprintBytes or 128
        if not id or #id > limit or (not activity and kind ~= "content"
            and kind ~= "vocabulary" and kind ~= "grammar") then return "malformed-exposure" end
        if activity or record.ready ~= nil or record.day ~= nil or record.used ~= nil then
            if not finite(record.ready) or record.ready < 0 or record.ready > record.expires
                or not amount(record.day) or record.day > e.day
                or record.ready < record.day * DAY
                or record.expires < (record.day + 1) * DAY
                or not amount(record.used) or record.used > 20000 then return "malformed-exposure" end
        end
    end
end
local function clockReason(self, state, now)
    if type(state) ~= "table" or not validTime(now) then return "invalid-time-or-state" end
    if not TT.Knowledge:IsSupported(state) then return "unsupported-knowledge-state" end
    if not TT.Knowledge:GetProgressEnabled(state) then return "progress-disabled" end
    -- Knowledge normalizes these upstream; reject rather than grant on bad input.
    if not amount(state.vocabularyXP) or state.vocabularyXP > 10000
        or not amount(state.grammarXP) or state.grammarXP > 10000 then return "invalid-knowledge-state" end
    local reason = exposureReason(self, state.exposure)
    if reason then return reason end
    if state.exposure and now < state.exposure.highWater then return "clock-rollback" end
end
local function receiveReason(self, state, context)
    if type(context) ~= "table" or context.eligible ~= true or context.isSelf then
        return "ineligible"
    end
    return clockReason(self, state, context.now)
end

-- Only forward time resets counters. Expiration, not insertion pressure, frees
-- history slots. Saved records contain canonical IDs/fingerprints and numbers,
-- never tokens, original chat text, sender accounts or channel metadata.
local function advance(state, now)
    local e = state.exposure
    local day = math.floor(now / DAY)
    if not e then
        e = { version = 1, highWater = now, day = day,
            vocabularyXP = 0, grammarXP = 0, records = {} }
        state.exposure = e
    end
    e.highWater = now
    if day > e.day then
        e.day, e.vocabularyXP, e.grammarXP = day, 0, 0
    end
    for id, record in pairs(e.records) do
        if now >= record.expires then e.records[id] = nil end
    end
    return e
end
local function active(e, id, now)
    local record = e and e.records[id]
    return record and now < record.expires and record or nil
end
local function size(e, now)
    local n = 0
    if e then
        for _, record in pairs(e.records) do
            if now < record.expires then n = n + 1 end
        end
    end
    return n
end
local function budget(self, state, axis, now)
    local e = state.exposure
    local used = e and math.floor(now / DAY) == e.day and e[axis .. "XP"] or 0
    return math.max(0, math.min(self.Config["daily" .. (axis == "vocabulary" and "Vocabulary" or "Grammar") .. "Cap"] - used,
        10000 - state[axis .. "XP"]))
end

-- Pure preview: no Knowledge mutation, pruning, clock advancement or allocation
-- into state. Both axes share the per-message cap. Reserve one point and one
-- history slot for eligible grammar, then allocate sorted vocabulary and grammar.
-- Call Observe, not this preview, to commit an award.
function P:CanObserve(state, document, context)
    local reason = receiveReason(self, state, context)
    if reason then return summary(reason) end
    local result = summary("no-new-units")
    if type(document) ~= "table" or type(document.fingerprint) ~= "string"
        or document.fingerprint == "" or #document.fingerprint > self.Config.maxFingerprintBytes then
        return summary("invalid-document")
    end
    local vocabulary = units("vocabulary", document.vocabulary)
    if #vocabulary < self.Config.minimumVocabularyDiversity then return summary("insufficient-diversity") end
    local now, e = context.now, state.exposure
    if active(e, "content:" .. document.fingerprint, now) then return summary("content-cooldown") end
    local slots = self.Config.historyLimit - size(e, now) - 1 -- reserve content
    local remaining = self.Config.messageCap
    local grammar = units("grammar", document.grammar)
    local reserve = 0
    if slots >= 2 and remaining >= 2 and budget(self, state, "vocabulary", now) > 0 then
        for _, id in ipairs(grammar) do
            if not active(e, "grammar:" .. id, now) then
                reserve = math.min(1, self.Config.grammarXP, budget(self, state, "grammar", now))
                break
            end
        end
    end
    for _, axis in ipairs({ "vocabulary", "grammar" }) do
        local available = budget(self, state, axis, now)
        local ids = axis == "vocabulary" and vocabulary or grammar
        local reservedXP = axis == "vocabulary" and reserve or 0
        local reservedSlots = reservedXP > 0 and 1 or 0
        for _, id in ipairs(ids) do
            local xp = math.min(self.Config[axis .. "XP"], available, remaining - reservedXP)
            if slots > reservedSlots and xp > 0 and not active(e, axis .. ":" .. id, now) then
                result[axis][#result[axis] + 1] = id
                result[axis .. "XP"] = result[axis .. "XP"] + xp
                available, remaining, slots = available - xp, remaining - xp, slots - 1
            end
        end
    end
    if result.vocabularyXP + result.grammarXP > 0 then result.reason = "awarded"
    elseif slots <= 0 then result.reason = "history-full" end
    return result
end
local function grant(state, e, result)
    if result.vocabularyXP + result.grammarXP == 0 then return end
    TT.Knowledge:Grant(state, result.vocabularyXP, result.grammarXP)
    e.vocabularyXP = e.vocabularyXP + result.vocabularyXP
    e.grammarXP = e.grammarXP + result.grammarXP
end
function P:Observe(state, document, context)
    local reason = receiveReason(self, state, context)
    if reason then return summary(reason) end
    local result = self:CanObserve(state, document, context)
    local e = advance(state, context.now)
    if result.reason ~= "awarded" then return result end
    grant(state, e, result)
    e.records["content:" .. document.fingerprint] = { expires = context.now + self.Config.contentCooldown }
    for _, axis in ipairs({ "vocabulary", "grammar" }) do
        for _, id in ipairs(result[axis]) do
            e.records[axis .. ":" .. id] = { expires = context.now + self.Config.unitCooldown }
        end
    end
    return result
end

-- Curated definitions: { vocabulary = { [catalogID] = requirement }, grammar =
-- { [constructionID] = requirement }, vocabularyXP = integer, grammarXP = integer }.
-- Registration copies definitions; no arbitrary chat or caller-supplied grant
-- amounts enter Study/Practice. The caller decides whether a lesson was completed or
-- an answer was correct. This cannot authenticate real-world learning locally.
local function register(self, registry, id, definition, cap)
    assert(type(id) == "string" and #id > 0 and #id <= 128, "invalid activity ID")
    assert(not registry[id], "duplicate activity ID")
    assert(type(definition) == "table", "invalid activity definition")
    local copy, total = {}, 0
    for _, axis in ipairs({ "vocabulary", "grammar" }) do
        local xp = definition[axis .. "XP"]
        if xp == nil then xp = 0 end
        assert(amount(xp) and xp <= cap, "invalid activity XP")
        local map = definition[axis]
        if map == nil then map = {} end
        assert(type(map) == "table", "invalid activity units")
        local ids = units(axis, map)
        local count = 0
        for _ in pairs(map) do count = count + 1 end
        assert(count == #ids and (xp == 0 or count > 0), "unregistered activity unit")
        copy[axis], copy[axis .. "XP"] = ids, xp
        total = total + xp
    end
    assert(total > 0 and total <= cap, "activity grant exceeds cap or is empty")
    registry[id] = copy
end
function P:RegisterLesson(id, definition)
    register(self, lessons, id, definition, self.Config.studyGrantCap)
end
function P:RegisterExercise(id, definition)
    register(self, exercises, id, definition, self.Config.practiceGrantCap)
end
local function activity(self, state, id, now, registry, kind, cap)
    local reason = clockReason(self, state, now)
    if reason then return summary(reason) end
    local definition = registry[id]
    local e = advance(state, now)
    if not definition then return summary("unknown-activity") end
    local key = kind .. ":" .. id
    local record = active(e, key, now)
    if record and now < record.ready then return summary("activity-cooldown") end
    if not record and size(e, now) >= self.Config.historyLimit then return summary("history-full") end
    local used = record and record.day == e.day and record.used or 0
    local remaining = math.min(cap, math.max(0, self.Config.activityDailyCap - used))
    local result = summary("daily-cap-or-full")
    for _, axis in ipairs({ "vocabulary", "grammar" }) do
        local xp = math.min(definition[axis .. "XP"], budget(self, state, axis, now), remaining)
        result[axis .. "XP"] = xp
        remaining = remaining - xp
        if xp > 0 then
            for _, unit in ipairs(definition[axis]) do result[axis][#result[axis] + 1] = unit end
        end
    end
    local total = result.vocabularyXP + result.grammarXP
    if total > 0 then
        result.reason = "awarded"
        grant(state, e, result)
        e.records[key] = { ready = now + self.Config.activityCooldown,
            expires = math.max(now + self.Config.activityCooldown, (e.day + 1) * DAY),
            day = e.day, used = used + total }
    end
    return result
end
function P:Study(state, lessonId, now)
    return activity(self, state, lessonId, now, lessons, "lesson", self.Config.studyGrantCap)
end
function P:Practice(state, exerciseId, now)
    return activity(self, state, exerciseId, now, exercises, "exercise", self.Config.practiceGrantCap)
end
