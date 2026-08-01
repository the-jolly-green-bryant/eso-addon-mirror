PITHKA = PITHKA or {}
PITHKA.groupFinder = PITHKA.groupFinder or {}

local GFStateMachine = ZO_Object:Subclass()

-- Debug function
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|c00FFFF[StateMachine]|r ' .. msg)
    end
end

-- States
GFStateMachine.STATES = {
    IDLE = "IDLE",           -- Not searching
    SEARCHING = "SEARCHING", -- Normal search cycle
    JOINING = "JOINING"     -- Performing targeted search for join
}

-- Events that can trigger state changes
GFStateMachine.EVENTS = {
    START_SEARCH = "START_SEARCH",
    STOP_SEARCH = "STOP_SEARCH",
    RESUME_SEARCH = "RESUME_SEARCH",
    JOIN_GROUP = "JOIN_GROUP",
    JOIN_COMPLETE = "JOIN_COMPLETE",
    JOIN_FAILED = "JOIN_FAILED"
}

function GFStateMachine:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function GFStateMachine:Initialize()
    self.currentState = self.STATES.IDLE
    self.previousState = nil
    self.stateData = {}
    self.stateCallbacks = {}
    
    -- Define state transitions
    self.transitions = {
        [self.STATES.IDLE] = {
            [self.EVENTS.STOP_SEARCH] = self.STATES.IDLE,
            [self.EVENTS.START_SEARCH] = self.STATES.SEARCHING
        },
        [self.STATES.SEARCHING] = {
            [self.EVENTS.STOP_SEARCH] = self.STATES.IDLE,
            [self.EVENTS.JOIN_GROUP] = self.STATES.JOINING
        },
        [self.STATES.JOINING] = {
            [self.EVENTS.JOIN_COMPLETE] = self.STATES.IDLE,
            [self.EVENTS.JOIN_FAILED] = self.STATES.IDLE,
            [self.EVENTS.STOP_SEARCH] = self.STATES.IDLE,
            [self.EVENTS.START_SEARCH] = self.STATES.SEARCHING  -- Allow background search during join dialog
        }
    }
end

function GFStateMachine:RegisterCallback(state, callback)
    self.stateCallbacks[state] = self.stateCallbacks[state] or {}
    table.insert(self.stateCallbacks[state], callback)
end

function GFStateMachine:UnregisterCallback(state, callback)
    if self.stateCallbacks[state] then
        for i, cb in ipairs(self.stateCallbacks[state]) do
            if cb == callback then
                table.remove(self.stateCallbacks[state], i)
                break
            end
        end
    end
end

function GFStateMachine:GetCurrentState()
    return self.currentState
end

function GFStateMachine:GetPreviousState()
    return self.previousState
end

function GFStateMachine:SetStateData(key, value)
    self.stateData[key] = value
end

function GFStateMachine:GetStateData(key)
    return self.stateData[key]
end

function GFStateMachine:ClearStateData()
    self.stateData = {}
end

function GFStateMachine:CanTransition(event)
    local possibleTransitions = self.transitions[self.currentState]
    return possibleTransitions and possibleTransitions[event] ~= nil
end

function GFStateMachine:HandleEvent(event, data)
    if not self:CanTransition(event) then
        debug(string.format("|cFF0000[StateMachine]|r Invalid transition: %s from state %s", event, self.currentState))
        return false
    end

    local newState = self.transitions[self.currentState][event]
    self:TransitionTo(newState, data)
    return true
end

function GFStateMachine:TransitionTo(newState, data)
    local oldState = self.currentState
    self.previousState = oldState
    self.currentState = newState

    -- Store transition data if provided
    if data then
        self:SetStateData("transitionData", data)
    end

    debug(string.format("|cFFFFFF[StateMachine]|r State change: %s -> %s", oldState, newState))

    -- Fire callbacks for the new state
    if self.stateCallbacks[newState] then
        for _, callback in ipairs(self.stateCallbacks[newState]) do
            callback(oldState, data)
        end
    end
end

PITHKA.groupFinder.StateMachine = GFStateMachine
