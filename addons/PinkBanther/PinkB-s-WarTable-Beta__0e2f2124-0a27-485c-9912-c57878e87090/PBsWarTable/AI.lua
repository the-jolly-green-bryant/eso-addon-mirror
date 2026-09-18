-- Beginner: deterministic one-action evaluation, no opponent tree search.
-- All candidates use the same Engine.Apply path as human commands.
local E, C = PBWT.Engine, PBWT.Config
local AI = {}; PBWT.AI = AI
local directions = { {1,0}, {-1,0}, {0,1}, {0,-1} }
local function distance(a,b) return math.abs(a.x-b.x)+math.abs(a.y-b.y) end

function AI.Candidates(s, player)
    local list = { {type="end_turn"} }
    if not E.Active(s, player) then return {} end
    if PBWT.Scroll.CanInvoke(s,player) then list[#list+1]={type='invoke_scroll'} end
    local function movement(p, kind, maximum, card)
        for _, d in ipairs(directions) do
            for step=1,maximum do
                local x,y=p.x+d[1]*step,p.y+d[2]*step
                if E.CanMove(s,p,x,y,maximum) then
                    list[#list+1]={type=kind,id=p.id,x=x,y=y,card=card}
                else break end -- A blocked square also blocks the longer straight path.
            end
        end
    end
    for _,p in ipairs(s.pieces) do
        if p.owner==player then
            if p.alive then
                if s.actions>0 then movement(p,"move",E.MoveRange(s,p)) end
                if s.horn[p.id] then movement(p,"horn_move",C.HORN_DISTANCE) end
                if s.cards[player].charge then movement(p,"card",C.CHARGE_DISTANCE,"charge") end
                if s.cards[player].stealth and p.kind=="scout" and not p.hiddenUntil then
                    list[#list+1]={type="card",card="stealth",id=p.id}
                end
                local hasNeighbor=false
                for _,other in ipairs(s.pieces) do
                    if other.alive and distance(p,other)==1 then
                        if other.owner==player then hasNeighbor=true
                        elseif s.actions>0 and E.CanAttack(s,p,other,false) then
                            list[#list+1]={type="attack",id=p.id,target=other.id}
                            if s.cards[player].siege and E.CanAttack(s,p,other,true) then
                                list[#list+1]={type="card",card="siege",id=p.id,target=other.id}
                            end
                        end
                    end
                end
                if hasNeighbor and s.cards[player].horn then list[#list+1]={type="card",card="horn",id=p.id} end
            elseif p.kind=="soldier" and s.cards[player].revive then
                for _,home in ipairs(C.START) do
                    local x=player==1 and home.x or C.SIZE+1-home.x
                    if not E.At(s,x,home.y) then list[#list+1]={type="card",card="revive",id=p.id,x=x,y=home.y} end
                end
            end
        end
    end
    return list
end

local function position(s,p,x,y)
    local best=0
    for i,f in ipairs(C.FLAGS) do
        local occupant=E.At(s,f.x,f.y)
        -- Do not send weak units toward an invulnerable enemy guardian.
        local reachable=not occupant or occupant.id==p.id or
            (occupant.owner~=p.owner and not occupant.hiddenUntil and E.Attack(s,p)>=E.Defense(s,occupant))
        if reachable then
            local d=math.abs(x-f.x)+math.abs(y-f.y)
            local value=math.max(0,C.SIZE*2-d)*C.AI.APPROACH_WEIGHT
            if x==f.x and y==f.y then value=value+f.points*C.AI.OCCUPY_WEIGHT end
            -- Uncontrolled flags receive extra attention, including the 2-point center.
            if s.flags[i]~=p.owner then value=value+f.points*2 end
            if value>best then best=value end
        end
    end
    return best
end
function AI.Evaluate(s,player)
    local W=C.AI
    if s.status=="finished" then
        if s.winner==0 then return 0 end
        return s.winner==player and W.WIN_VALUE or -W.WIN_VALUE
    end
    local score=(s.score[player]-s.score[3-player])*W.SCORE_WEIGHT
    if s.scrollOwner~=0 then score=score+(s.scrollOwner==player and 1 or -1)*C.SCROLL.THREAT_WEIGHT end
    for i,owner in ipairs(s.flags) do
        if owner~=0 then score=score+(owner==player and 1 or -1)*C.FLAGS[i].points*W.FLAG_WEIGHT end
    end
    for _,p in ipairs(s.pieces) do
        if p.alive then
            local value=W.PIECE_VALUE[p.kind]+position(s,p,p.x,p.y)
            if not p.hiddenUntil then
                for _,enemy in ipairs(s.pieces) do
                    if enemy.alive and enemy.owner~=p.owner and distance(p,enemy)==1 and E.Attack(s,enemy)>=E.Defense(s,p) then
                        value=value-W.PIECE_VALUE[p.kind]*W.THREAT_WEIGHT; break
                    end
                end
            end
            score=score+(p.owner==player and value or -value)
        end
    end
    for _,id in ipairs(C.CARD_ORDER) do
        if s.cards[player][id] then score=score+W.CARD_RESERVE end
        if s.cards[3-player][id] then score=score-W.CARD_RESERVE end
    end
    return score
end
-- A shallow mobility estimate lets the beginner understand an activated horn.
-- It is not a multi-move search: each neighbor is considered independently.
local function hornPotential(s,player)
    local value=0
    for _,p in ipairs(s.pieces) do
        if p.alive and p.owner==player and s.horn[p.id] then
            local gain=0
            for _,d in ipairs(directions) do
                local x,y=p.x+d[1],p.y+d[2]
                if E.CanMove(s,p,x,y,C.HORN_DISTANCE) then
                    local improvement=position(s,p,x,y)-position(s,p,p.x,p.y)
                    local owner,index=E.Flag(s,x,y)
                    if index and owner~=player then improvement=improvement+C.FLAGS[index].points*C.AI.SCORE_WEIGHT end
                    gain=math.max(gain,improvement)
                end
            end
            value=value+gain*C.AI.HORN_POTENTIAL
        end
    end
    return value
end
AI.HornPotential=hornPotential
function AI.Difficulty(id) return C.AI.DIFFICULTIES[id] and id or "beginner" end
function AI.NewSearch(s,player,difficulty)
    if not E.Active(s,player) then return nil end
    difficulty=AI.Difficulty(difficulty)
    if difficulty~="beginner" then return PBWT.Search.New(s,player,difficulty) end
    return {state=E.Clone(s),player=player,candidates=AI.Candidates(s,player),index=1,
        best=nil,bestScore=-math.huge,evaluated=0,done=false}
end
function AI.Step(job,budget)
    if job.advanced then return PBWT.Search.Step(job,budget) end
    if job.done then return true,job.best end
    local limit=math.max(1,math.floor(budget or C.AI.CANDIDATES_PER_TICK))
    for _=1,limit do
        local command=job.candidates[job.index]
        if not command then job.done=true; return true,job.best end
        job.index=job.index+1; job.evaluated=job.evaluated+1
        local simulation=E.Clone(job.state)
        local ok=E.Apply(simulation,job.player,command)
        if ok then
            local potential=hornPotential(simulation,job.player)
            if command.type~="end_turn" then E.Apply(simulation,job.player,{type="end_turn"}) end
            local value=AI.Evaluate(simulation,job.player)
            if simulation.status~="finished" then value=value+potential end
            -- Stable ties prefer end_turn, regular moves, and earlier piece IDs.
            if value>job.bestScore then job.bestScore,job.best=value,command end
            if command.type=="end_turn" and simulation.status=="finished" and simulation.winner==job.player then
                job.done=true; return true,job.best
            end
        end
    end
    job.done=job.index>#job.candidates
    return job.done,job.done and job.best or nil
end
