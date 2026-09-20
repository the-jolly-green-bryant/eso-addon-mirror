-- Personality only. No gameplay API or transport dependency.
SXUI_PetStateMachine = {}
local M = SXUI_PetStateMachine
M.__index = M
M.Durations = {BLINK=.28, DOUBLE_BLINK=.62, LOOK_LEFT=2.6, LOOK_RIGHT=2.6,
    IDLE_HAPPY=2.4, YAWN=4.2, HAND_WAVE=2.4, HAPPY_BOUNCE=1.9, HAND_FIDGET=1.6}
M.Aliases={IDLE_BLINK="BLINK",IDLE_DOUBLE_BLINK="DOUBLE_BLINK",
    IDLE_LOOK_LEFT="LOOK_LEFT",IDLE_LOOK_RIGHT="LOOK_RIGHT",
    IDLE_SLEEPY="YAWN",WAVE="HAND_WAVE"}

function M:New(seed)
    local machine = setmetatable({seed=math.max(1,math.floor(seed or 17)%2147483647)},self)
    machine:Reset()
    return machine
end

function M:Random(lo,hi)
    self.seed = (self.seed*16807)%2147483647
    return lo+(hi-lo)*self.seed/2147483647
end

function M:Reset()
    self.state,self.elapsed,self.time = "IDLE",0,0
    self.nextBlink = self:Random(3.5,7)
    self.nextGesture = self:Random(12,22)
    self.nextHappy = self:Random(35,55)
    self.nextYawn = self:Random(55,85)
end

function M:Play(state)
    state=self.Aliases[state] or state
    if self.state ~= "IDLE" or not self.Durations[state] then return false end
    self.state,self.elapsed = state,0
    return true
end

function M:Update(dt)
    self.time,self.elapsed = self.time+dt,self.elapsed+dt
    if self.state ~= "IDLE" then
        if self.elapsed >= self.Durations[self.state] then
            self.state,self.elapsed = "IDLE",0
            self.nextBlink = self.time+self:Random(3.5,7)
        end
        return
    end
    if self.time >= self.nextYawn then
        self:Play("YAWN")
        self.nextYawn = self.time+self:Random(80,140)
        self.nextGesture = self.time+self:Random(15,28)
    elseif self.time >= self.nextHappy then
        self:Play(self:Random(0,1)<.58 and "IDLE_HAPPY" or "HAPPY_BOUNCE")
        self.nextHappy = self.time+self:Random(45,75)
        self.nextGesture = self.time+self:Random(15,28)
    elseif self.time >= self.nextBlink then
        self:Play(self:Random(0,1)<.18 and "DOUBLE_BLINK" or "BLINK")
    elseif self.time >= self.nextGesture then
        local choice = self:Random(0,1)
        self:Play(choice<.28 and "LOOK_LEFT" or choice<.56 and "LOOK_RIGHT"
            or choice<.78 and "HAND_WAVE" or "HAND_FIDGET")
        self.nextGesture = self.time+self:Random(15,28)
    end
end
