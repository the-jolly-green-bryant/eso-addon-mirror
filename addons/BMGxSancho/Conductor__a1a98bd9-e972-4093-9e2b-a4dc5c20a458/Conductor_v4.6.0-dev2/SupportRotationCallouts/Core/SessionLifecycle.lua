local C = Conductor
C.SessionLifecycle = C.SessionLifecycle or {}
local Lifecycle = C.SessionLifecycle

local ALLOWED = {
    CREATED = { SHARED=true, ACTIVE=true, COMPLETED=true, ARCHIVED=true },
    SHARED = { ACTIVE=true, PAUSED=true, COMPLETED=true, ARCHIVED=true },
    ACTIVE = { PAUSED=true, COMPLETED=true, ARCHIVED=true },
    PAUSED = { ACTIVE=true, COMPLETED=true, ARCHIVED=true },
    COMPLETED = { ARCHIVED=true },
    ARCHIVED = {},
}

local function State() return C.RaidSession and C.RaidSession:GetActive() end

function Lifecycle:CanTransition(nextState)
    local session = State()
    if not session then return false end
    return ALLOWED[tostring(session.state or "") ] and ALLOWED[tostring(session.state or "")][nextState] == true
end

function Lifecycle:Transition(nextState, reason)
    local session = State()
    if not session or not self:CanTransition(nextState) then return false end
    if nextState == C.RaidSession.STATES.ARCHIVED then
        C.RaidSession:Archive(reason or "session lifecycle archived")
        return true
    end
    return C.RaidSession:Transition(nextState, reason or "session lifecycle transition")
end

function Lifecycle:Activate(reason) return self:Transition(C.RaidSession.STATES.ACTIVE, reason or "raid session activated") end
function Lifecycle:Pause(reason) return self:Transition(C.RaidSession.STATES.PAUSED, reason or "raid session paused") end
function Lifecycle:Resume(reason) return self:Activate(reason or "raid session resumed") end
function Lifecycle:Complete(reason) return self:Transition(C.RaidSession.STATES.COMPLETED, reason or "raid session completed") end
function Lifecycle:Archive(reason) return self:Transition(C.RaidSession.STATES.ARCHIVED, reason or "raid session archived") end

function Lifecycle:OnPlayerActivated()
    local session = State()
    if not session or session.state == C.RaidSession.STATES.ARCHIVED then return end
    if session.state == C.RaidSession.STATES.PAUSED then self:Resume("player returned") end
end

function Lifecycle:OnCombatState(_, inCombat)
    local session = State()
    if not session then return end
    if inCombat and (session.state == C.RaidSession.STATES.CREATED or session.state == C.RaidSession.STATES.SHARED or session.state == C.RaidSession.STATES.PAUSED) then
        self:Activate("group entered combat")
    end
end

function Lifecycle:Initialize()
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent("ConductorRaidSessionLifecycle", EVENT_PLAYER_COMBAT_STATE, function(...) self:OnCombatState(...) end)
        EVENT_MANAGER:RegisterForEvent("ConductorRaidSessionLifecycle", EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    end
    if C.EventBus then
        C.EventBus:Subscribe("RAID_SESSION_SHARED", self, function(payload)
            local session = payload and payload.session
            if session and session.state == C.RaidSession.STATES.CREATED then self:Transition(C.RaidSession.STATES.SHARED, "session shared") end
        end)
        C.EventBus:Subscribe("RAID_SESSION_STATE_CHANGED", self, function(payload)
            if payload and payload.state == C.RaidSession.STATES.COMPLETED then
                C.EventBus:Publish("RAID_SESSION_COMPLETED", payload)
            end
        end)
    end
    self.initialized = true
end
