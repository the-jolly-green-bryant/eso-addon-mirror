-- Engine is deliberately independent of ESO. Dependencies are injected for tests.
PBJ = PBJ or {}
local Game = {}
Game.__index = Game
PBJ.Game = Game
Game.CHOICE_SECONDS = 10
local active = { inviting=true, invited=true, choosing=true, locked=true }
local function integer(n, low, high)
    return type(n)=="number" and n==math.floor(n) and n>=low and n<=high
end
function Game.New(options)
    return setmetatable({o=options, state="idle", recent={}, cooldown={}, serial=0},Game)
end
function Game:Notify() if self.o.changed then self.o.changed(self) end end
function Game:IsActive() return active[self.state] == true end
function Game:Digest(name, choice, n1, n2)
    return PBJ.SHA256(table.concat({"PBJ2",self.session,name,choice,n1,n2}, ":")):sub(1,32)
end
function Game.Outcome(a,b)
    if a==0 then return "lose" end
    if b==0 then return "win" end
    if a==b then return "draw" end
    return (a-b)%3==1 and "win" or "lose" -- rock=1, paper=2, scissors=3
end
function Game:Reset(peer, session, state)
    self.peer, self.session, self.state = peer,session,state
    self.choice,self.otherChoice,self.commit,self.otherCommit,self.n1,self.n2=nil,nil,nil,nil,nil,nil
    self.revealSent,self.result,self.reason=false,nil,nil
    self.pendingReveal=nil
    self.choiceDeadline=nil
    self.retryAt=self.o.now()+8
    self.deadline=self.o.now()+60
end
function Game:Packet(kind, a,b,c,d)
    return {kind=kind,session=self.session,a=a or 0,b=b or 0,c=c or 0,d=d or 0}
end
function Game:Send(kind,a,b,c,d)
    if not self.o.send(self.peer,self:Packet(kind,a,b,c,d)) then
        self:Finish("error","sendFailed")
        return false
    end
    return true
end
function Game:Finish(state,reason)
    if self.peer and self.session then self.recent[self.peer..":"..self.session]=self.o.now()+120 end
    self.state,self.reason=state,reason
    self:Notify()
end
function Game:Invite(peer)
    if self:IsActive() or peer==self.o.name or not self.o.allowed(peer) then return false end
    self.serial=self.serial+1
    self:Reset(peer,(self.o.random()+self.serial)%4294967296,"inviting")
    if not self:Send(1) then return false end
    self:Notify()
    return true
end
function Game:Accept()
    if self.state~="invited" then return end
    self.state,self.deadline="choosing",self.o.now()+60
    self.choiceDeadline=self.o.now()+Game.CHOICE_SECONDS
    if self:Send(2) then self:Notify() end
end
function Game:Cancel(reason)
    if not self:IsActive() then return end
    self:Send(5)
    self:Finish("cancelled",reason or "cancelled")
end
function Game:Choose(choice)
    if self.state~="choosing" or not integer(choice,1,3) then return false end
    if self.o.now()>=self.choiceDeadline then self:Commit(0); return false end
    return self:Commit(choice)
end
function Game:Commit(choice)
    if self.state~="choosing" then return false end
    self.choice,self.n1,self.n2=choice,self.o.random(),self.o.random()
    self.commit=self:Digest(self.o.name,choice,self.n1,self.n2)
    self.state="locked"
    local parts={}
    for i=1,4 do parts[i]=tonumber(self.commit:sub(i*8-7,i*8),16) end
    if not self:Send(3,parts[1],parts[2],parts[3],parts[4]) then return false end
    self:MaybeReveal()
    self:Notify()
    return true
end
function Game:MaybeReveal()
    if self.state=="locked" and self.otherCommit and not self.revealSent then
        self.revealSent=true
        self:Send(4,self.choice,self.n1,self.n2)
    end
    if self.pendingReveal and self.state=="locked" and self.otherCommit then
        local packet=self.pendingReveal
        self.pendingReveal=nil
        self:Receive(self.peer,packet)
    end
end
function Game:Receive(sender,p)
    if type(p)~="table" or sender==self.o.name or not self.o.allowed(sender) then return end
    if not integer(p.kind,1,5) or not integer(p.session,0,4294967295) then return end
    for _,k in ipairs({"a","b","c","d"}) do if not integer(p[k],0,4294967295) then return end end
    local key=sender..":"..p.session
    -- A peer still retrying its commitment may have missed our reveal.
    if self.state=="result" and sender==self.peer and p.session==self.session and p.kind==3 then
        self.o.send(self.peer,self:Packet(4,self.choice,self.n1,self.n2))
        return
    end
    if self.recent[key] then return end
    if p.kind==1 then
        if self:IsActive() then
            if self.peer==sender and self.session==p.session then
                if self.state=="choosing" or self.state=="locked" then self:Send(2) end
                return
            end
            -- Resolve simultaneous invitations deterministically on both clients.
            if not (self.state=="inviting" and self.peer==sender and sender<self.o.name) then return end
            self.recent[self.peer..":"..self.session]=self.o.now()+120
        end
        if self.cooldown[sender] and self.o.now()<self.cooldown[sender] then return end
        self.cooldown[sender]=self.o.now()+10
        self:Reset(sender,p.session,"invited")
        self:Notify()
        return
    end
    if not self:IsActive() or sender~=self.peer or p.session~=self.session then return end
    if p.kind==5 then self:Finish("cancelled","peerCancelled"); return end
    if p.kind==2 and self.state=="inviting" then
        self.state,self.deadline="choosing",self.o.now()+60
        self.choiceDeadline=self.o.now()+Game.CHOICE_SECONDS
    elseif p.kind==3 and (self.state=="choosing" or self.state=="locked") then
        local digest=string.format("%08x%08x%08x%08x",p.a,p.b,p.c,p.d)
        if self.otherCommit and self.otherCommit~=digest then self:Cancel("invalidReveal"); return end
        self.otherCommit=digest
        self:MaybeReveal()
    elseif p.kind==4 and self.state=="locked" and not self.otherCommit then
        self.pendingReveal=p
    elseif p.kind==4 and self.state=="locked" and self.revealSent and self.otherCommit then
        if not integer(p.a,0,3) or self:Digest(sender,p.a,p.b,p.c)~=self.otherCommit then
            self:Cancel("invalidReveal"); return
        end
        self.otherChoice=p.a
        self.result=Game.Outcome(self.choice,self.otherChoice)
        local reason
        if self.choice==0 then reason=p.a==0 and "bothTimeLoss" or "timeLoss"
        elseif p.a==0 then reason="timeWin" end
        self:Finish("result",reason)
        return
    end
    self:Notify()
end
function Game:Tick()
    local now=self.o.now()
    for k,t in pairs(self.recent) do if t<=now then self.recent[k]=nil end end
    for k,t in pairs(self.cooldown) do if t<=now then self.cooldown[k]=nil end end
    if self:IsActive() then
        if not self.o.allowed(self.peer) then self:Cancel("unavailable")
        elseif self.state=="choosing" and now>=self.choiceDeadline then self:Commit(0)
        elseif now>=self.deadline then self:Cancel("timeout")
        elseif now>=self.retryAt then
            self.retryAt=now+8
            if self.state=="inviting" then self:Send(1)
            elseif self.state=="locked" then
                self:Send(3,tonumber(self.commit:sub(1,8),16),tonumber(self.commit:sub(9,16),16),
                    tonumber(self.commit:sub(17,24),16),tonumber(self.commit:sub(25,32),16))
                if self.state=="locked" and self.revealSent then self:Send(4,self.choice,self.n1,self.n2) end
            end
        end
    end
end
