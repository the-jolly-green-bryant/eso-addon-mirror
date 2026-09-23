-- Bounded beam search. The beam prunes alternatives; this is not exhaustive minimax.
-- Only a fully completed pass replaces the decision used if a budget expires.
local E,AI,C=PBWT.Engine,PBWT.AI,PBWT.Config
local S={}; PBWT.Search=S
local END={type='end_turn'}
local function simulate(job,state,actor,command)
    local raw=E.Clone(state)
    if not E.Apply(raw,actor,command) then return end
    local projected=E.Clone(raw)
    local potential=AI.HornPotential(raw,job.player)-AI.HornPotential(raw,3-job.player)
    if command.type~='end_turn' then E.Apply(projected,actor,END) end
    local score=AI.Evaluate(projected,job.player)
    if projected.status~='finished' then score=score+potential end
    job.evaluated=job.evaluated+1
    return {command=command,raw=raw,state=projected,score=score}
end
local function insert(beam,plan,width)
    local at=#beam+1
    for i,old in ipairs(beam) do if plan.score>old.score then at=i; break end end
    if at<=width then table.insert(beam,at,plan); if #beam>width then table.remove(beam) end end
end
local function run(job)
    local beam={}
    for _,command in ipairs(AI.Candidates(job.state,job.player)) do
        local plan=simulate(job,job.state,job.player,command)
        if plan then
            insert(beam,plan,job.profile.width)
            if not job.best or plan.score>job.bestScore then job.best,job.bestScore=command,plan.score end
            -- Immediate victory needs no further search; the actual command is still
            -- executed normally and followed by another decision if not end_turn.
            if plan.state.status=='finished' and plan.state.winner==job.player then
                job.completedPass='winning'; return
            end
            coroutine.yield()
        end
    end
    job.completedPass='basic'
    if job.profile.combinations then
        local combined={}
        for _,first in ipairs(beam) do
            local best=first
            if first.raw.status=='playing' and first.raw.player==job.player then
                for _,command in ipairs(AI.Candidates(first.raw,job.player)) do
                    local plan=simulate(job,first.raw,job.player,command)
                    if plan then
                        plan.command=first.command
                        if plan.score>best.score then best=plan end
                        coroutine.yield()
                    end
                end
            end
            insert(combined,best,job.profile.width)
        end
        beam=combined
        if beam[1] then job.best,job.bestScore=beam[1].command,beam[1].score end
        job.completedPass='combinations'
    end
    local best,bestScore=nil,-math.huge
    for _,plan in ipairs(beam) do
        local worst=plan.score
        if plan.state.status=='playing' then
            worst=math.huge
            local opponent=plan.state.player
            for _,reply in ipairs(AI.Candidates(plan.state,opponent)) do
                local response=simulate(job,plan.state,opponent,reply)
                if response then
                    worst=math.min(worst,response.score)
                    coroutine.yield()
                    if worst<=-C.AI.WIN_VALUE then break end
                end
            end
        end
        if worst>bestScore then best,bestScore=plan.command,worst end
    end
    if best then job.best,job.bestScore=best,bestScore end
    job.completedPass='opponent_reply'
end
function S.New(state,player,difficulty)
    local job={advanced=true,state=E.Clone(state),player=player,difficulty=difficulty,
        profile=C.AI.DIFFICULTIES[difficulty],best=nil,bestScore=-math.huge,evaluated=0,done=false}
    job.nodes=job.profile.nodes*(E.Rules(state).NODE_SCALE or 1)
    job.worker=coroutine.create(function() run(job) end)
    return job
end
function S.Step(job,budget)
    if job.done then return true,job.best end
    local limit=math.max(1,math.floor(budget or job.profile.perTick))
    for _=1,limit do
        if job.evaluated>=job.nodes then
            job.done,job.stopReason,job.worker=true,'node_budget',nil; break
        end
        local ok,err=coroutine.resume(job.worker)
        if not ok then error(err) end
        if coroutine.status(job.worker)=='dead' then
            job.done,job.worker=true,nil; break
        end
    end
    if job.done and not job.best then job.best=END end
    return job.done,job.done and job.best or nil
end
