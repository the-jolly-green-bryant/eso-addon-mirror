-- The Elder Scroll is a public, deterministic one-response-turn victory threat.
local R={}; PBWT.Scroll=R
function R.Reader(s)
    return s.scrollOwner~=0 and PBWT.Engine.Piece(s,s.scrollReader) or nil
end
function R.Position(s,player)
    local E,C=PBWT.Engine,PBWT.Config
    local flag=C.FLAGS[C.SCROLL.CENTER_FLAG]
    local p=E.At(s,flag.x,flag.y)
    if not p or p.owner~=player or p.hiddenUntil then return false,'scroll_reader' end
    local count=E.Counts(s,player)
    if s.flags[C.SCROLL.CENTER_FLAG]~=player or count<C.SCROLL.FLAGS_REQUIRED then return false,'scroll_flags' end
    for _,f in ipairs(C.FLAGS) do
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
    if s.turn>=C.MAX_TURNS then return false,'scroll_too_late' end
    if s.actions<1 then return false,'no_action' end
    if s.score[player]<C.SCROLL.COST then return false,'scroll_score' end
    return R.Position(s,player)
end
function R.Invoke(s,player)
    local ok,p=R.CanInvoke(s,player); if not ok then return false,p end
    s.score[player]=s.score[player]-PBWT.Config.SCROLL.COST
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
    if s.status=='finished' and s.reason=='elder_scroll' then return '星霜の書が帝位を定めた\nP'..s.winner..'：星霜勝利' end
    if s.scrollOwner~=0 then
        return 'P'..s.scrollOwner..'が開封中：読者の防御1\n相手の手番終了で星霜勝利\n阻止：読者撃破 / 敵が旗へ進入'
    end
    return '星霜の書：'..(s.scrollUsed[player] and '使用済み' or '未使用')..'\n4点＋通常行動で開封（各軍1回）\n中央含む2旗支配・中央に自軍札\n敵が旗にいないこと / 隠密不可'
end
