local BA = BMGAdventures
BA.UnlockEngine = BA.UnlockEngine or {}

function BA.UnlockEngine:Initialize() end

function BA.UnlockEngine:HasUnlock(id)
    return BA.account.unlocks[id] == true
end

function BA.UnlockEngine:Grant(id)
    if not id or BA.account.unlocks[id] then return false end
    BA.account.unlocks[id] = true
    BA.Diagnostics:Count("unlocksGranted")
    BA.EventBus:Publish("UNLOCK_GRANTED", { id=id })
    return true
end
