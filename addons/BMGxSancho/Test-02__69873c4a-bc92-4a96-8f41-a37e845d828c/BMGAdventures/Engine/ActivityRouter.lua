local BA = BMGAdventures
BA.ActivityRouter = BA.ActivityRouter or {}

function BA.ActivityRouter:Initialize()
    self.recent = {}
end

local function makeFingerprint(event)
    local subject = event.subject and event.subject.activityId or "ANY"
    local raw = table.concat({event.activityType or "?", tostring(subject), tostring(event.correlation and event.correlation.runId or ""), tostring(event.eventId or "")}, "|")
    return raw
end

function BA.ActivityRouter:Publish(event)
    if type(event) ~= "table" or not event.activityType then return false end
    event.timestamp = event.timestamp or (GetTimeStamp and GetTimeStamp() or 0)
    event.eventId = event.eventId or tostring(event.timestamp) .. ":" .. tostring(math.random(1000000))
    event.actor = event.actor or { account = GetDisplayName and GetDisplayName() or "" }
    event.evidence = event.evidence or { detectionClass="OBSERVED", source="UNKNOWN" }
    event.subject = event.subject or {}
    event.result = event.result or { quantity=1 }

    local fp = makeFingerprint(event)
    if self.recent[fp] then return false end
    self.recent[fp] = event.timestamp
    local cutoff = event.timestamp - 5
    for k, t in pairs(self.recent) do if t < cutoff then self.recent[k] = nil end end

    BA.Diagnostics:Count("normalizedEvents")
    BA.Diagnostics:Record("ACTIVITY", event.activityType .. ":" .. tostring(event.subject.activityId or ""))
    BA.EventBus:Publish("ACTIVITY_RECEIVED", event)
    BA.ChallengeEngine:ProcessActivity(event)
    return true
end
