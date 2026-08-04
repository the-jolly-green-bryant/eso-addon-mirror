local C = Conductor
local SRC = SupportRotationCallouts
SRC.EncounterExecutionRuntime = SRC.EncounterExecutionRuntime or {}
C.EncounterExecutionRuntime = SRC.EncounterExecutionRuntime
local Runtime = SRC.EncounterExecutionRuntime

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Key(value) return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_") end

local PUBLIC_INSTRUCTIONS = {
    HOLD=true, CONTROLLED_PUSH=true, SPAMMABLES_ONLY=true, PREPARE_BURN=true,
    FULL_BURN=true, EXECUTE=true, RECOVERY=true, TRANSITION=true, WIPE=true,
}

function Runtime:PublishContext(step, status)
    if not step or step.persistentInstruction ~= true or not PUBLIC_INSTRUCTIONS[Key(step.windowType or step.key)] then return end
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local profile = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.profile or nil
    local instruction = Key(step.windowType or step.key)
    local data = {
        sessionId=session and session.sessionId or "",
        encounterId=profile and profile.id or "",
        state=SRC.EncounterStateEngine and SRC.EncounterStateEngine.state or "ACTIVE",
        instruction=instruction, windowId=step.windowId or "",
        revision=(self.revision or 0)+1, status=status or "ACTIVE",
    }
    self.revision = data.revision
    if C.PublicRaidContext then C.PublicRaidContext:Publish(data) end
end

function Runtime:OnPublicContext(payload)
    local context = payload and payload.context
    if not context then return end
    local personal = C.PersonalSession and C.PersonalSession:GetActive() or nil
    if personal then return end -- accepted participants use the full execution plan
    if C.TimelineEngine then
        C.TimelineEngine:AddEvent({
            id="PUBLIC-" .. tostring(context.revision or NowMs()), key=context.instruction,
            label=Key(context.instruction):gsub("_"," "), targetMs=NowMs(), lane="RAID",
            audiences={"all"}, publicContext=true, priority=30,
        })
    end
end

function Runtime:Initialize()
    self.revision = 0
    if C.EventBus then
        C.EventBus:Subscribe("SEQUENCE_STEP_SCHEDULED", self, function(payload)
            self:PublishContext(payload and payload.step, "SCHEDULED")
        end)
        C.EventBus:Subscribe("SEQUENCE_STEP_COMPLETED", self, function(payload)
            self:PublishContext(payload and payload.step, "CONFIRMED")
        end)
        C.EventBus:Subscribe("PUBLIC_RAID_CONTEXT_UPDATED", self, function(payload) self:OnPublicContext(payload) end)
        C.EventBus:Subscribe("ENCOUNTER_SIGNAL_OBSERVED", self, function(payload)
            if SRC.EncounterSequenceEngine and payload then
                SRC.EncounterSequenceEngine:ObserveTrigger("SIGNAL", payload.key or payload.id, payload)
            end
        end)
        C.EventBus:Subscribe("ENCOUNTER_STATE_CHANGED", self, function(payload)
            local state = Key(payload and (payload.state or payload.nextState))
            if SRC.EncounterSequenceEngine then SRC.EncounterSequenceEngine:ObserveTrigger("ENCOUNTER_STATE", state, payload) end
            if (state == "COMPLETE" or state == "INACTIVE") and C.PublicRaidContext and C.PublicRaidContext:IsHost() then
                C.PublicRaidContext:Publish({sessionId=(C.RaidSession:GetActive() or {}).sessionId, state=state, instruction=state, revision=self.revision+1})
            end
        end)
    end
    self.initialized = true
end
