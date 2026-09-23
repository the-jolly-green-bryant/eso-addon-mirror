-- The Elder Scroll is a public, deterministic one-response-turn victory threat.
local R={}; PBWT.Scroll=R
function R.Reader(s)
    return s.scrollOwner~=0 and PBWT.Engine.Piece(s,s.scrollReader) or nil
end
function R.Position(s,player)
    local E=PBWT.Engine
    local rules=E.Rules(s); local scroll=rules.SCROLL
    -- The reader stands on the seat of the empire: the centre keep on the light board,
    -- the Imperial City itself on the standard one.
    local p=E.At(s,scroll.SQUARE.x,scroll.SQUARE.y)
    if not p or p.owner~=player or p.hiddenUntil then return false,'scroll_reader' end
    local count=E.Counts(s,player)
    if scroll.SQUARE_IS_FLAG then
        local owner,index=E.Flag(s,scroll.SQUARE.x,scroll.SQUARE.y)
        if owner~=player then return false,'scroll_flags' end
    end
    if count<scroll.FLAGS_REQUIRED then return false,'scroll_flags' end
    for _,f in ipairs(rules.FLAGS) do
        local enemy=E.At(s,f.x,f.y)
        if enemy and enemy.owner~=player then return false,'scroll_contested' end
    end
    return true,p
end
function R.CanInvoke(s,player)
    local E,C=PBWT.Engine,PBWT.Config
    local ok,why=E.Active(s,player); if not ok then return false,why end
    if s.scrollOwner~=0 then return false,'scroll_active' end
    if s.scrollUsed[player] then return false,'scroll_spent' end
    if s.turn>=E.Rules(s).MAX_TURNS then return false,'scroll_too_late' end
    if s.actions<1 then return false,'no_action' end
    if s.score[player]<E.Rules(s).SCROLL.COST then return false,'scroll_score' end
    return R.Position(s,player)
end
function R.Invoke(s,player)
    local ok,p=R.CanInvoke(s,player); if not ok then return false,p end
    s.score[player]=s.score[player]-PBWT.Engine.Rules(s).SCROLL.COST
    s.actions=s.actions-1; s.scrollUsed[player]=true
    s.scrollOwner,s.scrollReader,s.scrollTurn=player,p.id,s.turn
    return true,'scroll_invoked'
end
function R.Check(s)
    if s.scrollOwner==0 then return false end
    local p=R.Reader(s)
    local valid,current=R.Position(s,s.scrollOwner)
    if not p or not p.alive or not valid or current.id~=p.id then
        s.scrollOwner,s.scrollReader,s.scrollTurn=0,0,0
        return true -- Opening is spent even if the reader later returns.
    end
    return false
end
function R.Resolve(s,endingPlayer)
    R.Check(s)
    if s.scrollOwner~=0 and endingPlayer~=s.scrollOwner and s.turn==s.scrollTurn+1 then
        s.status,s.winner,s.reason='finished',s.scrollOwner,'elder_scroll'
        return true
    end
    return false
end
function R.Text(s,player)
    if s.status=='finished' and s.reason=='elder_scroll' then return PBWT.L("scroll_won")..s.winner..PBWT.L("scroll_won_suffix") end
    if s.scrollOwner~=0 then
        return 'P'..s.scrollOwner..PBWT.L("scroll_active_text")
    end
    local rules=PBWT.Engine.Rules(s); local scroll=rules.SCROLL
    local seat=scroll.SQUARE_IS_FLAG and PBWT.L("scroll_seat_flag") or PBWT.L("scroll_seat_city")
    return PBWT.L("scroll_label")..(s.scrollUsed[player] and PBWT.L("scroll_spent") or PBWT.L("scroll_ready"))..'\n'..scroll.COST..PBWT.L("scroll_cost_line")..seat..PBWT.L("scroll_need_a")..scroll.FLAGS_REQUIRED..PBWT.L("scroll_need_b")
end
