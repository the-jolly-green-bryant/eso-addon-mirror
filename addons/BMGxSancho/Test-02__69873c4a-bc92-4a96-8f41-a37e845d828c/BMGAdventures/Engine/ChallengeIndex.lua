local BA = BMGAdventures
BA.ChallengeIndex = BA.ChallengeIndex or {}

function BA.ChallengeIndex:Build()
    self.byActivity = {}
    self.meta = {}
    self.byId = {}
    for _, def in ipairs(BA.Challenges) do
        self.byId[def.id] = def
        if def.activityType == "PROFILE_META" then
            self.meta[#self.meta+1] = def
        else
            local bucket = self.byActivity[def.activityType]
            if not bucket then bucket = {}; self.byActivity[def.activityType] = bucket end
            bucket[#bucket+1] = def
        end
    end
end

function BA.ChallengeIndex:GetCandidates(event)
    local bucket = self.byActivity[event.activityType] or {}
    local out = {}
    local subjectId = event.subject and event.subject.activityId
    for _, def in ipairs(bucket) do
        if not def.subjectId or def.subjectId == subjectId then out[#out+1] = def end
    end
    BA.Diagnostics:Count("challengeCandidates", #out)
    if #out > (BA.Diagnostics.metrics.maxCandidates or 0) then BA.Diagnostics.metrics.maxCandidates = #out end
    return out
end
