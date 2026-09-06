local BA = BMGAdventures
BA.CollectionEngine = BA.CollectionEngine or {}

function BA.CollectionEngine:Initialize()
    self.byChallenge = {}
    for collectionId, collection in pairs(BA.Collections or {}) do
        for _, challengeId in ipairs(collection.required or {}) do
            self.byChallenge[challengeId] = self.byChallenge[challengeId] or {}
            table.insert(self.byChallenge[challengeId], collectionId)
        end
    end

    BA.EventBus:Subscribe("CHALLENGE_COMPLETED", function(payload)
        if not payload or not payload.challenge then return end
        self:RefreshForChallenge(payload.challenge.id)
    end)

    self:ReconcileAll(false)
end

function BA.CollectionEngine:GetState(collectionId)
    BA.account.collections[collectionId] = BA.account.collections[collectionId] or { v=0, c=false }
    return BA.account.collections[collectionId]
end

function BA.CollectionEngine:CountCompletedMembers(collection)
    local completed = 0
    for _, challengeId in ipairs(collection.required or {}) do
        local state = BA.account.challenges[challengeId]
        if state and state.c then completed = completed + 1 end
    end
    return completed
end

function BA.CollectionEngine:RefreshCollection(collectionId, publish)
    local collection = BA.Collections and BA.Collections[collectionId]
    if not collection then return false end

    local state = self:GetState(collectionId)
    local value = self:CountCompletedMembers(collection)
    local goal = #(collection.required or {})
    local changed = value ~= (state.v or 0)
    state.v = value

    if goal > 0 and value >= goal and not state.c then
        state.c = true
        state.t = GetTimeStamp and GetTimeStamp() or 0
        BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
        BA.Diagnostics:Count("collectionsCompleted")
        BA.Diagnostics:Record("COLLECTION_COMPLETE", collectionId)
        if publish ~= false then
            BA.EventBus:Publish("COLLECTION_COMPLETED", { collection=collection, state=state })
            BA.EventBus:Publish("PROFILE_CHANGED", { revision=BA.account.profileRevision })
        end
        return true
    end

    if changed and publish ~= false then
        BA.EventBus:Publish("COLLECTION_PROGRESS", { collection=collection, state=state })
    end
    return changed
end

function BA.CollectionEngine:RefreshForChallenge(challengeId)
    for _, collectionId in ipairs(self.byChallenge[challengeId] or {}) do
        self:RefreshCollection(collectionId, true)
    end
end

function BA.CollectionEngine:ReconcileAll(publish)
    for collectionId in pairs(BA.Collections or {}) do
        self:RefreshCollection(collectionId, publish)
    end
end

function BA.CollectionEngine:GetCompletedCount()
    local count = 0
    for collectionId in pairs(BA.Collections or {}) do
        local state = BA.account.collections[collectionId]
        if state and state.c then count = count + 1 end
    end
    return count
end

function BA.CollectionEngine:GetSummary()
    local rows = {}
    for collectionId, collection in pairs(BA.Collections or {}) do
        local state = self:GetState(collectionId)
        local goal = #(collection.required or {})
        rows[#rows+1] = string.format("%s %s [%d/%d]", state.c and "|c66FF66✓|r" or "|cAAAAAA•|r", collection.name or collectionId, state.v or 0, goal)
    end
    table.sort(rows)
    return table.concat(rows, "\n")
end
