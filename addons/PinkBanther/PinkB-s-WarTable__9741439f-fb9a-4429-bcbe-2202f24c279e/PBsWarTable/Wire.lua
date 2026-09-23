local W={}; PBWT.Wire=W
W.K={INVITE=1,ACCEPT=2,START=3,READY=4,REQUEST=5,COMMIT=6,ACK=7,SYNC=8,REPLAY=9,REPLAY_ACK=10,RESIGN=11,CLOSE=12,PING=13,PONG=14,DECLINE=15}
local names={[1]='end_turn',[2]='move',[3]='attack',[4]='horn_move',[10]='resign',[11]='choose_faction',[12]='invoke_scroll',[13]='roll_dice',[14]='choose_right',[15]='choose_order'}
local cards={[5]='charge',[6]='stealth',[7]='siege',[8]='revive',[9]='horn',[16]='supply'}
function W.Integer(n,max) return type(n)=='number' and n==math.floor(n) and n>=0 and n<=max end
function W.Pack(c,actor)
    local code
    for n,name in pairs(names) do if c.type==name then code=n end end
    if c.type=='card' then for n,name in pairs(cards) do if c.card==name then code=n end end end
    if not code or (actor~=1 and actor~=2) then return nil end
    local id,target,x,y=c.id or 0,c.target or 0,c.x or 0,c.y or 0
    if code==13 then id,target,x,y=c.roll or 0,0,0,0
    elseif code==14 or code==15 then id,target,x,y=c.choice or 0,0,0,0
    elseif code==11 then id,target,x,y=c.faction or 0,0,0,0
    elseif code==1 or code==10 or code==12 then id,target,x,y=0,0,0,0
    elseif code==2 or code==4 or code==5 or code==8 then target=0
    elseif code==3 or code==7 then x,y=0,0
    else target,x,y=0,0,0 end
    local C=PBWT.Config
    if not W.Integer(id,C.MAX_PIECES) or not W.Integer(target,C.MAX_PIECES)
        or not W.Integer(x,C.MAX_BOARD) or not W.Integer(y,C.MAX_BOARD) then return nil end
    return actor*8388608+(((code*32+id)*32+target)*16+x)*16+y
end
function W.Unpack(value)
    if not W.Integer(value,25165823) then return end
    local actor=math.floor(value/8388608); value=value%8388608
    if actor~=1 and actor~=2 then return end
    local y=value%16; value=math.floor(value/16)
    local x=value%16; value=math.floor(value/16)
    local target=value%32; value=math.floor(value/32)
    local id=value%32; local code=math.floor(value/32)
    if not names[code] and not cards[code] then return end
    local C=PBWT.Config
    if id>C.MAX_PIECES or target>C.MAX_PIECES or x>C.MAX_BOARD or y>C.MAX_BOARD then return end
    local c={type=names[code] or 'card',card=cards[code]}
    if code==13 then
        if id>6 or target+x+y~=0 then return end
        if id>0 then c.roll=id end -- Zero is a request, never a replayable outcome.
    elseif code==14 or code==15 then
        if id<1 or id>2 or target+x+y~=0 then return end
        c.choice=id
    elseif code==11 then
        if id<1 or id>3 or target+x+y~=0 then return end
        c.faction=id
    elseif code==1 or code==10 or code==12 then if id+target+x+y~=0 then return end
    elseif code==2 or code==4 or code==5 or code==8 then
        if id==0 or x==0 or y==0 or target~=0 then return end
        c.id,c.x,c.y=id,x,y
    elseif code==3 or code==7 then
        if id==0 or target==0 or x+y~=0 then return end
        c.id,c.target=id,target
    else
        if id==0 or target+x+y~=0 then return end
        c.id=id
    end
    return c,actor
end
function W.Apply(s,actor,command)
    if command.type=='resign' then
        if (s.status~='playing' and s.status~='setup') or (actor~=1 and actor~=2) then return false,'finished' end
        s.status,s.winner,s.reason='finished',3-actor,'resign'; return true,'resigned'
    end
    return PBWT.Engine.Apply(s,actor,command)
end
