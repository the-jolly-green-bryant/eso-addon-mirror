local C = Conductor
C.SequenceRuntime = C.SequenceRuntime or {}
local Runtime = C.SequenceRuntime

local function Copy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k,v in pairs(value) do out[k] = Copy(v) end
    return out
end

function Runtime:Publish(name, payload)
    if C.EventBus then C.EventBus:Publish(name, payload) end
end

function Runtime:Reset(reason)
    self.state = {
        active=false, profileId=nil, stage="IDLE", currentStep=nil,
        pending={}, completed={}, failed={}, revision=(self.state and self.state.revision or 0)+1,
        reason=reason or "sequence reset",
    }
    self:Sync(reason)
end

function Runtime:Sync(reason)
    if C.RuntimeContext then C.RuntimeContext:Patch("sequence", self.state, reason or "sequence runtime changed") end
    self:Publish("SEQUENCE_RUNTIME_CHANGED", {state=self.state, reason=reason})
end

function Runtime:RebuildFromEngine(reason)
    local engine = C.EncounterSequenceEngine
    if not engine then return end
    local pending, completed, failed, current = {}, {}, {}, nil
    for _,step in ipairs(engine.steps or {}) do
        local item = {id=step.id,key=step.key,label=step.label,status=step.status,responsibilityKey=step.responsibilityKey,assignedAccount=step.assignedAccount,targetMs=step.targetMs}
        if step.status == "COMPLETE" or step.status == "SKIPPED" then completed[#completed+1]=item
        elseif step.status == "MISSED" then failed[#failed+1]=item
        else
            pending[#pending+1]=item
            if not current and (step.status == "SCHEDULED" or step.status == "WAITING") then current=item end
        end
    end
    local stage = current and (current.responsibilityKey or current.key) or (engine.state or "IDLE")
    self.state = {
        active=engine.state == engine.STATE.RUNNING or engine.state == engine.STATE.PAUSED or engine.state == engine.STATE.INTERRUPTED,
        profileId=engine.profile and engine.profile.id or nil,
        stage=stage,
        currentStep=current,
        pending=pending,
        completed=completed,
        failed=failed,
        revision=(self.state and self.state.revision or 0)+1,
        reason=reason,
    }
    self:Sync(reason)
end

function Runtime:RegisterEvents()
    if not C.EventBus then return end
    local rebuild = {"SEQUENCE_STARTED","SEQUENCE_STEP_SCHEDULED","SEQUENCE_STEP_COMPLETED","SEQUENCE_STEP_SKIPPED","SEQUENCE_STEP_MISSED","SEQUENCE_PAUSED","SEQUENCE_RESUMED","SEQUENCE_INTERRUPTED","SEQUENCE_COMPLETED"}
    for _,name in ipairs(rebuild) do C.EventBus:Subscribe(name, self, function() self:RebuildFromEngine(name) end) end
    C.EventBus:Subscribe("LIVE_SESSION_CHANGED", self, function(payload) self:Reset((payload and payload.reason) or "live session changed") end)
    C.EventBus:Subscribe("RUNTIME_CONTEXT_INVALIDATED", self, function(payload) self:Reset((payload and payload.reason) or "runtime invalidated") end)
end

function Runtime:GetSnapshot() return Copy(self.state or {}) end
function Runtime:Initialize()
    self:Reset("initialize")
    self:RegisterEvents()
    self.initialized=true
end
