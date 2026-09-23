-- Timer-independent match driver. The UI owns scheduling and visibility.
local E,C=PBWT.Engine,PBWT.Config
local Solo={}; Solo.__index=Solo; PBWT.Solo=Solo
function Solo.New(state,difficulty,clock)
    return setmetatable({state=state,player=2,paused=true,job=nil,due=0,
        difficulty=PBWT.AI.Difficulty(difficulty),clock=clock},Solo)
end
function Solo:IsTurn()
    return (self.state.status=="playing" or self.state.status=="setup") and self.state.player==self.player
end
function Solo:Pause()
    self.paused=true; self.job=nil
end
function Solo:Resume(now)
    self.paused=false; self.job=nil; self.due=now+C.AI.THINK_DELAY_MS
end
function Solo:Tick(now)
    if self.paused or not self:IsTurn() or now<self.due then return end
    if self.state.status=='setup' then
        local command=PBWT.Opening.ComputerCommand(self.state)
        local ok,reason=E.Apply(self.state,self.player,command)
        self.due=now+C.AI.THINK_DELAY_MS
        return command,ok,reason
    end
    if not self.job then self.job=PBWT.AI.NewSearch(self.state,self.player,self.difficulty); self.searchStarted=now end
    local profile=C.AI.DIFFICULTIES[self.difficulty]
    local started=self.clock and self.clock()
    local done,command
    for _=1,profile.perTick do
        done,command=PBWT.AI.Step(self.job,1)
        if done or (self.clock and self.clock()-started>=C.AI.SLICE_MS) then break end
    end
    if not done and now-self.searchStarted>=C.AI.MAX_THINK_MS then
        done,command=true,self.job.best or {type="end_turn"}
        self.job.stopReason="time_budget"
    end
    if not done then return end
    self.lastSearch={nodes=self.job.evaluated,pass=self.job.completedPass or "basic",reason=self.job.stopReason or "complete"}
    self.job=nil
    -- Revalidate through Engine.Apply even after the search snapshot.
    local ok,reason=E.Apply(self.state,self.player,command or {type="end_turn"})
    if not ok then
        -- A stale/invalid result must not leave the player stuck waiting forever.
        command={type="end_turn"}; ok,reason=E.Apply(self.state,self.player,command)
    end
    self.due=now+C.AI.THINK_DELAY_MS
    return command,ok,reason
end
