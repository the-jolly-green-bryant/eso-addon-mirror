-- Cosmetic RNG is private: no shared personality RNG and no protocol inputs.
SXUI_FlameTint={time=0,amount=0,seed=nil,nextAt=nil}
local T=SXUI_FlameTint
function T:Random()
    self.seed=(self.seed or (GetGameTimeMilliseconds()+7919))%2147483647
    self.seed=(self.seed*16807)%2147483647
    return self.seed/2147483647
end
function T:Update(dt)
    self.time=self.time+math.max(0,math.min(.1,dt))
    if not self.nextAt then self.nextAt=self.time+45+self:Random()*75 end
    if not self.started and self.time>=self.nextAt then
        self.started=self.time;self.duration=3+self:Random()*3
        self.color=self:Random()<.5 and {.28,.66,1} or {.32,1,.46}
    end
    self.amount=0
    if self.started then
        local elapsed=self.time-self.started
        local v=math.min(1,elapsed/1.2,(self.duration+2.4-elapsed)/1.2)
        v=math.max(0,v);self.amount=v*v*(3-2*v)
        if elapsed>=self.duration+2.4 then
            self.started=nil;self.nextAt=self.time+45+self:Random()*75
        end
    end
end
function T:Apply(control)
    local v=self.amount
    local color=self.color or {1,1,1}
    control:SetDesaturation(v)
    control:SetColor(1+(color[1]-1)*v,1+(color[2]-1)*v,1+(color[3]-1)*v,1)
end
